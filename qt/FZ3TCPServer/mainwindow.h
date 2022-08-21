#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include <QMainWindow>
#include <QDebug>
#include <QFile>
#include <QFileDialog>
#include <QMessageBox>
#include <QMetaType>
#include <QSet>
#include <QStandardPaths>
#include <QTcpServer>
#include <QTcpSocket>
#include <QMetaObject>

#include <iostream>
#include <stdlib.h>
#include <stdio.h>
#include <stdbool.h>
#include <string.h> // Strlen function

#include <fcntl.h>	   // Flags for open()
#include <sys/stat.h>  // Open() system call
#include <sys/types.h> // Types for open()
#include <sys/mman.h>  // Mmap system call
#include <sys/ioctl.h> // IOCTL system call
#include <unistd.h>	   // Close() system call
#include <sys/time.h>  // Timing functions and definitions
#include <getopt.h>	   // Option parsing
#include <errno.h>	   // Error codes

#include "AXIDMA/libaxidma.h"  // Interface to the AXI DMA
#include "AXIDMA/util.h"	   // Miscellaneous utilities
#include "AXIDMA/conversion.h" // Miscellaneous conversion utilities
#include "AXIDMA/axidma_benchmark.h"
#include "AXIDMA/xdma_lb_axis_switch.h"

#include <atomic>
#include <thread>

#define BUFFER_SIZE 1

namespace Ui
{
	class MainWindow;
}

class MainWindow : public QMainWindow
{
	Q_OBJECT

public:
	explicit MainWindow(QWidget *parent = nullptr);
	~MainWindow();

signals:
	void newMessage(QString);
    void showMessageBox(const QString &title, const QString &text);
private slots:
	void newConnection();
	void appendToSocketList(QTcpSocket *socket);
	void discardSocket();
	void displayError(QAbstractSocket::SocketError socketError);
	void displayMessage(const QString &str);
	void refreshComboBox();
	void init_dma();
	void on_pushButton_init_dma_clicked();
	void sendDataToClient(QTcpSocket *socket, QByteArray *fileDataPtr);
	void on_pushButton_stopSendData_clicked();
	void on_pushButton_sendData_clicked();
	void sendDataAsync(QString receiver);
	void getSensorData(bool dma_init_done);
    void on_showMessageBox(const QString &title, const QString &text);

private:
	Ui::MainWindow *ui;
	QTcpServer *m_server;
    QMap<QString, QTcpSocket *> connection_set;
	int rc;
	int tx_channel, rx_channel;
	int num_transfers = 10;
	size_t tx_size, rx_size;
	char *tx_buf, *rx_buf;
	axidma_dev_t axidma_dev;
	const array_t *tx_chans, *rx_chans;
	struct axidma_inout_transaction trans;
	XDma_lb_axis_switch loop_back_sw;
	bool dma_init_done;
	QString LastLogQstring;
	QByteArray processedData;
	QByteArray fileData;
	std::atomic_bool sensor_data_stream;
	std::atomic_bool sensor_data_available;
    QTcpSocket *_socket;
};

#endif // MAINWINDOW_H
