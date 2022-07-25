#include "mainwindow.h"
#include "ui_mainwindow.h"

MainWindow::MainWindow(QWidget *parent) : QMainWindow(parent), ui(new Ui::MainWindow)
{
	ui->setupUi(this);
	ui->pushButton_init_dma->setEnabled(false);
	m_server = new QTcpServer();

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
	ui->pushButton_init_dma->setEnabled(true);
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
	int tx_size_init = 10;
	int rx_size_init = 10;
	tx_channel = 0;
	rx_channel = 1;
	tx_size = MIB_TO_BYTE(tx_size_init);
	rx_size = MIB_TO_BYTE(rx_size_init);

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
	XDma_lb_axis_switch loop_back_sw;
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
	XDma_lb_axis_switch_Set_dma_loopback_en(&loop_back_sw, 1);
	LastLogQstring = "AXI DMA sw loopback enabled";
	ui->textBrowser_receivedMessages->append(LastLogQstring);
	std::cout << LastLogQstring.toStdString() << std::endl;

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

	XDma_lb_axis_switch_Set_dma_loopback_en(&loop_back_sw, 0);
	XDma_lb_axis_switch_Release(&loop_back_sw);
	LastLogQstring = "AXI DMA sw loopback disabled";
	ui->textBrowser_receivedMessages->append(LastLogQstring);
	std::cout << LastLogQstring.toStdString() << std::endl;
	ui->pushButton_init_dma->setEnabled(false);
	LastLogQstring = "DMA test DONE";
	ui->textBrowser_receivedMessages->append(LastLogQstring);
	std::cout << LastLogQstring.toStdString() << std::endl;

	QString receiver = "DMA initialize DONE";
}

void MainWindow::on_pushButton_init_dma_clicked()
{
	init_dma();
}

void MainWindow::on_pushButton_sendData_clicked()
{

	QString receiver = ui->comboBox_receiver->currentText();

	QByteArray fileData;
    for (int i = 0; i < 100000; i++)
	{
		fileData.prepend(QByteArray::fromHex("41"));
	}
    for (int i = 0; i < 100000; i++)
	{
		fileData.append(QByteArray::fromHex("42"));
	}
    for (int i = 0; i < 100000; i++)
	{
		fileData.append(QByteArray::fromHex("43"));
	}

	foreach (QTcpSocket *socket, connection_set)
	{
		if (socket->socketDescriptor() == receiver.toLongLong())
		{
			sendDataToClient(socket, &fileData, fileData.size());
			break;
		}
	}
}

void MainWindow::sendDataToClient(QTcpSocket *socket, QByteArray *fileDataPtr, unsigned long long fileDataSize)
{
	if (socket)
	{
		if (socket->isOpen())
		{
			int64_t bytes;
			QByteArray data = *fileDataPtr;
			QString tmpHeader = "fileType:fz3_data: ";
			QByteArray header = tmpHeader.toLocal8Bit();
            data.prepend(header);
//			bytes = socket->write(header);
//			while (socket->waitForBytesWritten())
//			{
//				usleep(10);
//			}

//			int packetSize = 100000;
//			unsigned long long numberOfPacket = fileDataSize / packetSize;
//			unsigned long long currentPacket = 0;

//			while (currentPacket < numberOfPacket)
//			{
//				bytes = socket->write(data.left(packetSize));
//				while (socket->waitForBytesWritten())
//				{
//					usleep(10);
//				}
//				data.remove(0, packetSize);
//				currentPacket++;
//			}

			QString tmpFooter = "A5A5A5A5A5A5A5A5";
			QByteArray footer = tmpFooter.toLocal8Bit();
            data.append(footer);
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
