package main

import (
	"fmt"
	"io/ioutil"
	"log"
	"net"
	"os"
	"os/exec"
	"os/user"
	"regexp"
	"strconv"
	"strings"
)

const (
	Saddr = ":12321"
)

func check(e error) {
	if e != nil {
		panic(e)
	}
}

func home() string {
	usr, _ := user.Current()
	homedir := usr.HomeDir
	return homedir
}

func status() string {
	current_path := home() + "/current"
	data, err := ioutil.ReadFile(current_path)
	check(err)
	return strings.TrimSpace(string(data))
}

func number(addr string) (num int) {
	match, _ := regexp.MatchString("192.168.\\d{1,3}.100", addr)
	if match {
		parts := strings.Split(addr, ".")
		n := parts[2]
		num, _ = strconv.Atoi(n)
	} else {
		num = 0
	}
	return
}

func fexist(path string) bool {
	if _, err := os.Stat(path); os.IsNotExist(err) {
		return false
	} else {
		return true
	}
}

func main() {
	p := fmt.Println
	server, err := net.Listen("tcp", Saddr)
	if err != nil {
		p("Server Starting failed")
	}
	for {
		conn, err := server.Accept()
		if err != nil {
			p("Server Accepting failed")
			continue
		}
		go handleConnection(conn)
	}
	os.Exit(0)
}

func handleConnection(conn net.Conn) {
	logfile, _ := os.OpenFile(home()+"/nethelper.log", os.O_RDWR|os.O_CREATE|os.O_APPEND, 0666)
	defer logfile.Close()
	log.SetOutput(logfile)
	p := fmt.Println
	defer conn.Close()
	client_ip := conn.RemoteAddr().String()
	log.Println(" - " + client_ip + " connected. ")
	num := number(client_ip)
	yu := num % 2
	neibor := ""
	if yu == 0 {
		neibor = strconv.Itoa(num - 1)
	} else {
		neibor = strconv.Itoa(num + 1)
	}

	buf := make([]byte, 512)
	for {
		n, err := conn.Read(buf[0:])
		if err != nil {
			p("Client connection error:", err)
			conn.Close()
			return
		}
		msg := strings.TrimSpace(string(buf[0:n]))
		fpath := ""
		if msg == "current" {
			conn.Write([]byte(status() + "\n"))
		} else if msg == "net" {
			if status() == "allnet" || status() == "net"+neibor {
				fpath = home() + "/allnet"
			} else {
				fpath = home() + "/net" + strconv.Itoa(num)
			}

			if fexist(fpath) {
				cmd := exec.Command("sh", "-c", fpath)
				err := cmd.Start()
				if err != nil {
					p(fpath + " File not existed")
				}
				conn.Write([]byte("net_ok\n"))
				log.Println(" - " + client_ip + " open the net.")
			} else {
				conn.Write([]byte("net_error\n"))
			}
		} else if msg == "school" {
			if status() == "allnet" || status() == "net"+neibor {
				fpath = home() + "/net" + neibor
			} else {
				fpath = home() + "/school"
			}
			if fexist(fpath) {
				cmd := exec.Command("sh", "-c", fpath)
				err := cmd.Start()
				if err != nil {
					p(fpath + " File not existed")
				}
				conn.Write([]byte("school_ok\n"))
			} else {
				conn.Write([]byte("school_error\n"))
			}
		} else if msg == "close" {
			log.Println(" - " + client_ip + " closed.")
			break
		}
	}
}
