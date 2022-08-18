#include "mainwindow.h"
#include "ui_mainwindow.h"

MainWindow::MainWindow(QWidget *parent) : QMainWindow(parent), ui(new Ui::MainWindow), sensor_data_stream(false)
{
	ui->setupUi(this);
	ui->pushButton_sendData->setEnabled(false);
	ui->pushButton_stopSendData->setEnabled(false);
	m_server = new QTcpServer();
	sensor_data_stream = 0;

	if (m_server->listen(QHostAddress::Any, 1992))
	{
		connect(this, &MainWindow::newMessage, this, &MainWindow::displayMessage);
		connect(m_server, &QTcpServer::newConnection, this, &MainWindow::newConnection);
		ui->statusBar->showMessage("Server is listening...");
	}
	else
	{
		QMessageBox::critical(this, "QTCPServer", QString("Unable to start the server: %1.").arg(m_server->errorString()));
		exit(EXIT_FAILURE);
	}
}

MainWindow::~MainWindow()
{
	foreach (QTcpSocket *socket, connection_set)
	{
		socket->close();
		socket->deleteLater();
		socket->setSocketOption(QAbstractSocket::SendBufferSizeSocketOption, 64 * 1024 * 1024);
	}

	m_server->close();
	m_server->deleteLater();

	delete ui;
}

void MainWindow::newConnection()
{
	while (m_server->hasPendingConnections())
		appendToSocketList(m_server->nextPendingConnection());
}

void MainWindow::appendToSocketList(QTcpSocket *socket)
{
	connection_set.insert(socket);
	connect(socket, &QTcpSocket::disconnected, this, &MainWindow::discardSocket);
	ui->comboBox_receiver->addItem(QString::number(socket->socketDescriptor()));
	displayMessage(QString("INFO :: Client with sockd:%1 has just entered the room").arg(socket->socketDescriptor()));
}

void MainWindow::discardSocket()
{
	QTcpSocket *socket = reinterpret_cast<QTcpSocket *>(sender());
	QSet<QTcpSocket *>::iterator it = connection_set.find(socket);
	if (it != connection_set.end())
	{
		displayMessage(QString("INFO :: A client has just left the room").arg(socket->socketDescriptor()));
		connection_set.remove(*it);
	}
	refreshComboBox();

	socket->deleteLater();
}

void MainWindow::displayError(QAbstractSocket::SocketError socketError)
{
	switch (socketError)
	{
	case QAbstractSocket::RemoteHostClosedError:
		break;
	case QAbstractSocket::HostNotFoundError:
		QMessageBox::information(this, "QTCPServer", "The host was not found. Please check the host name and port settings.");
		break;
	case QAbstractSocket::ConnectionRefusedError:
		QMessageBox::information(this, "QTCPServer", "The connection was refused by the peer. Make sure QTCPServer is running, and check that the host name and port settings are correct.");
		break;
	default:
		QTcpSocket *socket = qobject_cast<QTcpSocket *>(sender());
		QMessageBox::information(this, "QTCPServer", QString("The following error occurred: %1.").arg(socket->errorString()));
		break;
	}
}

void MainWindow::displayMessage(const QString &str)
{
	ui->textBrowser_receivedMessages->append(str);
}

void MainWindow::refreshComboBox()
{
	ui->comboBox_receiver->clear();
	foreach (QTcpSocket *socket, connection_set)
		ui->comboBox_receiver->addItem(QString::number(socket->socketDescriptor()));
}

void MainWindow::init_dma()
{
	tx_channel = 0;
	rx_channel = 1;
	tx_size = MIB_TO_BYTE(10);
	rx_size = MIB_TO_BYTE(10);
	LastLogQstring = "AXI DMA Parameters:";
	ui->textBrowser_receivedMessages->append(LastLogQstring);
	std::cout << LastLogQstring.toStdString() << std::endl;
	LastLogQstring = "Transmit Buffer Size:" + QString::number(BYTE_TO_MIB(tx_size)) + " MiB";
	ui->textBrowser_receivedMessages->append(LastLogQstring);
	std::cout << LastLogQstring.toStdString() << std::endl;
	;
	LastLogQstring = "Receive Buffer Size:" + QString::number(BYTE_TO_MIB(rx_size)) + " MiB";
	ui->textBrowser_receivedMessages->append(LastLogQstring);
	std::cout << LastLogQstring.toStdString() << std::endl;
	// setup axis switch
	const char *loop_back_sw_name = "dma_lb_axis_switch";
	int sw_init_status = 0;
	sw_init_status = XDma_lb_axis_switch_Initialize(&loop_back_sw, loop_back_sw_name);
	if (sw_init_status != 0)
	{
		LastLogQstring = "AXI DMA sw initialize failed with code:" + QString::number(BYTE_TO_MIB(sw_init_status));
		ui->textBrowser_receivedMessages->append(LastLogQstring);
		std::cout << LastLogQstring.toStdString() << std::endl;
	}
	else
	{
		LastLogQstring = "AXI DMA sw initialized";
		ui->textBrowser_receivedMessages->append(LastLogQstring);
		std::cout << LastLogQstring.toStdString() << std::endl;
	}

	// Initialize the AXI DMA device
	axidma_dev = axidma_init();
	if (axidma_dev == NULL)
	{
		LastLogQstring = "Failed to initialize the AXI DMA device.";
		ui->textBrowser_receivedMessages->append(LastLogQstring);
		std::cout << LastLogQstring.toStdString() << std::endl;
		rc = 1;
	}

	// Map memory regions for the transmit and receive buffers
	tx_buf = static_cast<char *>(axidma_malloc(axidma_dev, tx_size));
	if (tx_buf == NULL)
	{
		LastLogQstring = "Unable to allocate transmit buffer from the AXI DMA device.";
		ui->textBrowser_receivedMessages->append(LastLogQstring);
		std::cout << LastLogQstring.toStdString() << std::endl;
		rc = -1;
		axidma_destroy(axidma_dev);
	}
	rx_buf = static_cast<char *>(axidma_malloc(axidma_dev, rx_size));
	if (rx_buf == NULL)
	{
		LastLogQstring = "Unable to allocate receive buffer from the AXI DMA device";
		ui->textBrowser_receivedMessages->append(LastLogQstring);
		std::cout << LastLogQstring.toStdString() << std::endl;
		rc = -1;
		axidma_free(axidma_dev, tx_buf, tx_size);
		axidma_destroy(axidma_dev);
	}

	// Get all the transmit and receive channels
	tx_chans = axidma_get_dma_tx(axidma_dev);
	rx_chans = axidma_get_dma_rx(axidma_dev);

	if (tx_chans->len < 1)
	{
		LastLogQstring = "Error: No transmit channels were found.";
		ui->textBrowser_receivedMessages->append(LastLogQstring);
		std::cout << LastLogQstring.toStdString() << std::endl;
		rc = -ENODEV;
		axidma_free(axidma_dev, rx_buf, rx_size);
		axidma_free(axidma_dev, tx_buf, tx_size);
		axidma_destroy(axidma_dev);
	}
	if (rx_chans->len < 1)
	{
		LastLogQstring = "Error: No receive channels were found.";
		ui->textBrowser_receivedMessages->append(LastLogQstring);
		std::cout << LastLogQstring.toStdString() << std::endl;
		rc = -ENODEV;
		axidma_free(axidma_dev, rx_buf, rx_size);
		axidma_free(axidma_dev, tx_buf, tx_size);
		axidma_destroy(axidma_dev);
	}

	/* If the user didn't specify the channels, we assume that the transmit and
	 * receive channels are the lowest numbered ones. */
	if (tx_channel == -1 && rx_channel == -1)
	{
		tx_channel = tx_chans->data[0];
		rx_channel = rx_chans->data[0];
	}
	LastLogQstring = "Using transmit channel " + QString::number(tx_channel) + " and receive channel " + QString::number(rx_channel);
	ui->textBrowser_receivedMessages->append(LastLogQstring);
	std::cout << LastLogQstring.toStdString() << std::endl;

	dma_init_done = true;
	sensor_data_available = false;
	QString receiver = "DMA initialize DONE";
	ui->pushButton_init_dma->setEnabled(false);
	std::thread sendthread(&MainWindow::getSensorData, this, dma_init_done);
	sendthread.detach();
}

void MainWindow::on_pushButton_init_dma_clicked()
{
	init_dma();
	ui->pushButton_sendData->setEnabled(true);
}

void MainWindow::sendDataToClient(QTcpSocket *socket, QByteArray *fileDataPtr)
{
	if (socket)
	{
		if (socket->isOpen())
		{

			uint64_t bytes;
			QByteArray data = *fileDataPtr;
			bytes = socket->write(data);
			while (socket->waitForBytesWritten())
			{
				usleep(10);
			}
		}
		else
			QMessageBox::critical(this, "QTCPServer", "Socket doesn't seem to be opened");
	}
	else
		QMessageBox::critical(this, "QTCPServer", "Not connected");
}

void MainWindow::on_pushButton_sendData_clicked()
{
	QString receiver = ui->comboBox_receiver->currentText();
	ui->pushButton_sendData->setEnabled(false);
	ui->pushButton_stopSendData->setEnabled(true);
	sensor_data_stream = true;

	std::thread sendthread(&MainWindow::sendDataAsync, this, receiver);
	sendthread.detach();
}

void MainWindow::on_pushButton_stopSendData_clicked()
{
	sensor_data_stream = false;
	ui->pushButton_sendData->setEnabled(true);
	ui->pushButton_stopSendData->setEnabled(false);
}

void MainWindow::sendDataAsync(QString receiver)
{

	foreach (QTcpSocket *socket, connection_set)
	{
		if (socket->socketDescriptor() == receiver.toLongLong())
		{
			while (sensor_data_stream)
			{
				if (sensor_data_available)
				{
					sendDataToClient(socket, &fileData);
					fileData.resize(1);
					sensor_data_available = false;
				}
				else
				{
					usleep(10);
				}
			}
			QString tmpFooter = "A5A5A5A5A5A5A5A5";
			QByteArray footer = tmpFooter.toLocal8Bit();
			LastLogQstring = "send footer";
			ui->textBrowser_receivedMessages->append(LastLogQstring);
			std::cout << LastLogQstring.toStdString() << std::endl;
			sendDataToClient(socket, &footer);
			usleep(100);
		}
	}
}

void MainWindow::getSensorData(bool dma_init_done)
{
	QByteArray dma_raw_data;
	int counter_data = 0;
	while (dma_init_done)
	{
		/* This performs a one-way transfer over AXI DMA, the direction being specified
		 * by the user. The user determines if this is blocking or not with `wait. */
		rc = axidma_oneway_transfer(axidma_dev, rx_channel, rx_buf, rx_size, true);
		if (rc < 0)
		{
			LastLogQstring = "Failed to perform the AXI DMA read transfer";
			ui->textBrowser_receivedMessages->append(LastLogQstring);
			std::cout << LastLogQstring.toStdString() << std::endl;
		}
		QByteArray dma_raw_data(QByteArray::fromRawData(rx_buf, rx_size));

		QByteArray header_value(QByteArray::fromHex("AAAAAAAA"));
		int header_index = dma_raw_data.indexOf(header_value);

		while (header_index > 0)
		{
			processedData.append(QByteArray::fromHex("AAAAAAAA"));		 // header
			processedData.append(dma_raw_data.mid(header_index + 4, 4)); // time stamp
			processedData.append(counter_data);							 // todo data1
			processedData.append(counter_data + 1);						 // todo data2
			processedData.append(QByteArray::fromHex("55555555"));		 // footer
			dma_raw_data.remove(header_index, header_index + FRAME_SIZE);
			header_index = dma_raw_data.indexOf(header_value);
			counter_data = counter_data + 2;
		}

		if (processedData.size() > PACKET_SIZE)
		{
			processedData.remove(1, processedData.size());
			if (!sensor_data_available)
			{
				fileData.append(processedData);
				sensor_data_available = true;
			}
		}
	}
}
