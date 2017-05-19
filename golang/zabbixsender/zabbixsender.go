package main

import (
    "fmt"
    "flag"
    . "github.com/blacked/go-zabbix"
)

func main() {

    // load command line args
    zserver := flag.String("zabbix","","zabbix server e.g. '127.0.0.1'")
    targetHost := flag.String("host","","zabbix target host e.g. 'myhost'")
    zport := flag.Int("port",10051,"zabbix server port e.g. 10051")
    flag.Parse()

    // make sure required fields 'zabbix' and 'host' are populated
    if *zserver=="" || *targetHost=="" {
      flag.PrintDefaults()
      return
    }

    // debug
    fmt.Printf("Connecting to %s:%d to populate trapper items for host %s\n",*zserver,*zport,*targetHost)
    fmt.Printf("NOTE: If you do not have items of type trapper on host %s named 'mystr1' and 'myint1', then do not expect these keys to be successfuly processed\n\n",*targetHost)

    // prepare to send values to trapper items: myint1, mystr1
    var metrics []*Metric
    metrics = append(metrics, NewMetric(*targetHost, "myint1", "122"))
    metrics = append(metrics, NewMetric(*targetHost, "mystr1", "OK1"))

    // Create instance of Packet class
    packet := NewPacket(metrics)

    // Send packet to zabbix
    z := NewSender(*zserver, *zport)
    res,err := z.Send(packet)

    // check for error
    if err != nil {
      fmt.Println("ERROR: ",err)
      return
    }

    // show zabbix server reply
    fmt.Println(string(res))
}

