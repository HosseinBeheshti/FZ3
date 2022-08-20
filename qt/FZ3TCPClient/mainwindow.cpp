#include "mainwindow.h"
#include "ui_mainwindow.h"

MainWindow::MainWindow(QWidget *parent) : QMainWindow(parent),
										  ui(new Ui::MainWindow)
{
	ui->setupUi(this);

	QValidator *ip_validator = new QIntValidator(0, 255, this);
	ui->lineEdit_ip1->setValidator(ip_validator);
	ui->lineEdit_ip2->setValidator(ip_validator);
	ui->lineEdit_ip3->setValidator(ip_validator);
	ui->lineEdit_ip4->setValidator(ip_validator);
	ui->lineEdit_ip1->setText("10");
	ui->lineEdit_ip2->setText("1");
	ui->lineEdit_ip3->setText("1");
	ui->lineEdit_ip4->setText("11");
	ui->lineEdit_path->setText("~/");
	QValidator *file_size_validator = new QIntValidator(1, 4000, this);
	ui->lineEdit_file_size->setValidator(file_size_validator);
	ui->lineEdit_file_size->setText("60");

	socket = new QTcpSocket(this);
	socket->setSocketOption(QAbstractSocket::ReceiveBufferSizeSocketOption, 64 * 1024 * 1024);

	connect(this, &MainWindow::newMessage, this, &MainWindow::displayMessage);
	connect(socket, &QTcpSocket::readyRead, this, &MainWindow::readSocket);
	connect(socket, &QTcpSocket::disconnected, this, &MainWindow::discardSocket);
}

MainWindow::~MainWindow()
{
	if (socket->isOpen())
		socket->close();
}

void MainWindow::readSocket()
{
	socket_buffer.append(socket->readAll());
	int save_file_size = (ui->lineEdit_file_size->text()).toInt() * 1000 * 1000;
	if ((socket_buffer.size() >= save_file_size) || (socket_buffer.left(16) == "A5A5A5A5A5A5A5A5"))
	{

		ui->pushButton_path->setEnabled(false);
		QString file_time = QTime::currentTime().toString("hh:mm:ss");
		QString saveFilePath = filePath + "sensor_data_" + file_time + ".bin";
		QFile file(saveFilePath);
		if (file.open(QIODevice::WriteOnly))
		{
			file.write(socket_buffer);
			QString message = QString("INFO :: Attachment from sd:%1 successfully stored on disk under the path %2").arg(socket->socketDescriptor()).arg(QString(saveFilePath));
			emit newMessage(message);
			socket_buffer.remove(1, socket_buffer.size());
		}
		ui->pushButton_path->setEnabled(true);
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

void MainWindow::on_pushButton_connect_clicked()
{
	QString server_ip = ui->lineEdit_ip4->text() + "." + ui->lineEdit_ip3->text() + "." + ui->lineEdit_ip2->text() + "." + ui->lineEdit_ip1->text();
	socket->connectToHost(server_ip, 1992);

	if (socket->waitForConnected())
	{
		ui->statusBar->showMessage("Connected to Server");
		ui->pushButton_connect->setEnabled(false);
		ui->lineEdit_ip1->setReadOnly(true);
		ui->lineEdit_ip2->setReadOnly(true);
		ui->lineEdit_ip3->setReadOnly(true);
		ui->lineEdit_ip4->setReadOnly(true);
		ui->lineEdit_file_size->setReadOnly(true);
	}
	else
	{
		QMessageBox::critical(this, "QTCPClient", QString("The following error occurred: %1.").arg(socket->errorString()));
		exit(EXIT_FAILURE);
	}
}

void MainWindow::on_pushButton_path_clicked()
{
	filePath = QFileDialog::getSaveFileName(this, tr("Set path"), QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation) + "/");
	ui->lineEdit_path->setText(filePath);
}
