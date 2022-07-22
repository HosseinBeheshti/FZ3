#include "mainwindow.h"
#include "ui_mainwindow.h"

MainWindow::MainWindow(QWidget *parent) : QMainWindow(parent),
										  ui(new Ui::MainWindow)
{
	ui->setupUi(this);
	socket = new QTcpSocket(this);

	connect(this, &MainWindow::newMessage, this, &MainWindow::displayMessage);
	connect(socket, &QTcpSocket::readyRead, this, &MainWindow::readSocket);
	connect(socket, &QTcpSocket::disconnected, this, &MainWindow::discardSocket);

	socket->connectToHost(QHostAddress::LocalHost, 1992);

	if (socket->waitForConnected())
		ui->statusBar->showMessage("Connected to Server");
	else
	{
		QMessageBox::critical(this, "QTCPClient", QString("The following error occurred: %1.").arg(socket->errorString()));
		exit(EXIT_FAILURE);
	}
}

MainWindow::~MainWindow()
{
	if (socket->isOpen())
		socket->close();
	delete ui;
}

void MainWindow::readSocket()
{
	QByteArray buffer;
	QByteArray fullBuffer;
	bool footerPacketRecieved = 0;
	while (!footerPacketRecieved)
	{
		while (socket->bytesAvailable() > 0)
		{
			buffer.append(socket->readAll());
			fullBuffer = fullBuffer + buffer;
		}
		if (buffer.right(16) == "A5A5A5A5A5A5A5A5")
		{
			footerPacketRecieved = 1;
		}
	}
	QString file_time = QTime::currentTime().toString("hh:mm:ss");
	QString filePath = "/tmp/fz3_data/sensor_data_" + file_time + ".bin";
	QFile file(filePath);
	if (file.open(QIODevice::WriteOnly))
	{
		file.write(fullBuffer);
		QString message = QString("INFO :: Attachment from sd:%1 successfully stored on disk under the path %2").arg(socket->socketDescriptor()).arg(QString(filePath));
		emit newMessage(message);
	}
}

void MainWindow::discardSocket()
{
	socket->deleteLater();
	socket = nullptr;

	ui->statusBar->showMessage("Disconnected!");
}

void MainWindow::displayError(QAbstractSocket::SocketError socketError)
{
	switch (socketError)
	{
	case QAbstractSocket::RemoteHostClosedError:
		break;
	case QAbstractSocket::HostNotFoundError:
		QMessageBox::information(this, "QTCPClient", "The host was not found. Please check the host name and port settings.");
		break;
	case QAbstractSocket::ConnectionRefusedError:
		QMessageBox::information(this, "QTCPClient", "The connection was refused by the peer. Make sure QTCPServer is running, and check that the host name and port settings are correct.");
		break;
	default:
		QMessageBox::information(this, "QTCPClient", QString("The following error occurred: %1.").arg(socket->errorString()));
		break;
	}
}

void MainWindow::displayMessage(const QString &str)
{
	ui->textBrowser_receivedMessages->append(str);
}
