#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <arpa/inet.h>
#include <stdio.h>
#include <time.h>
#include <ctype.h>
#include "tuntcp.h"

int main(void)
{
	int tun = openTun("tun0");
	int tun1 = openTun("tun1");
	struct tcp_conn conn;
	struct tcp_conn conn1;
	TCPConnection(tun, "192.0.3.1", 1395, &conn);
	TCPConnection1(tun, "192.0.3.1", 1395, &conn1);

	char buffer[1024] = {0};
	char buffer1[1024] = {0};

	// Sending a SYN packet
	send_tcp_packet(&conn, TCP_SYN);
	send_tcp_packet1(&conn1, TCP_SYN);
	conn.state = TCP_SYN_SENT;
	conn1.state = TCP_SYN_SENT;

	read(tun, buffer, sizeof(buffer));
	read(tun1, buffer1, sizeof(buffer1));

	struct ipv4 *ip = buf2ip(buffer);
	struct ipv4 *ip1 = buf2ip(buffer1);
	struct tcp *tcp = buf2tcp(buffer, ip);
	struct tcp *tcp1 = buf2tcp(buffer1, ip1);
	int tcplen = ipdlen(ip);
	int tcplen1 = ipdlen(ip1);

	conn.seq = ntohl(tcp->ack);
	conn.ack = ntohl(tcp->seq) + 1;
	conn1.seq = ntohl(tcp->ack);
	conn1.ack = ntohl(tcp->seq) + 1;

	// Sending an ACK packet
	send_tcp_packet(&conn, TCP_ACK);
	send_tcp_packet1(&conn1, TCP_ACK);
	conn.state = TCP_ESTABLISHED;
	conn1.state = TCP_ESTABLISHED;

	// Sending a RST packet
	send_tcp_packet(&conn, TCP_RST);
	send_tcp_packet1(&conn1, TCP_RST);
	conn.state = TCP_CLOSED;
	conn1.state = TCP_CLOSED;

	return 0;
}
