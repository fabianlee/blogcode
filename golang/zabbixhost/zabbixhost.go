package main

import (
        //"github.com/rday/zabbix"
	// fork has support for logout, templates, hostgroup
        "github.com/fabianlee/zabbix"
	"fmt"
	"flag"
        "os"
	"encoding/json"
)

func main() {

    // load command line args
    zserver := flag.String("zabbix","","zabbix server address, e.g. 'http://127.0.0.1'")
    user := flag.String("user","","zabbix user, e.g. 'Admin'")
    pass := flag.String("pass","","zabbix password e.g. 'zabbix'")
    hostName :=  flag.String("host","","zabbix agent host name")
    hostGroupName := flag.String("group","","hostgroup name e.g. 'Linux servers'")
    templateName :=  flag.String("template","","template name e.g. 'Template OS Linux'")
    IP :=  flag.String("IP","","IP address of zabbix agent")
    flag.Parse()

    // make sure all vars are populated
    if *zserver=="" || *user=="" || *pass=="" || *hostName=="" || *hostGroupName=="" || *templateName=="" || *IP=="" {
	flag.PrintDefaults()
        os.Exit(1)
    }

    fmt.Printf("Going to connect to %s/zabbix/api_jsonrpc.php as %s\n",*zserver,*user)


    // define connection settings
    api, err := zabbix.NewAPI(*zserver + "/zabbix/api_jsonrpc.php", *user, *pass)
    if err != nil {
        fmt.Println(err)
        return
    }

    // check API version, session not required
    versionresult, err := api.Version()
    if err != nil {
        fmt.Println(err)
    }
    fmt.Println(versionresult)

    // login, get session with zabbix server
    _, err = api.Login()
    if err != nil {
        fmt.Println(err)
        return
    }
    fmt.Println("Connected to API")
    //ShowSelfDetails(api)



    // lookup template id
    templateId := GetTemplateId(api,*templateName)
    if templateId == "" {
	fmt.Println("Could not resolve templateId, exiting")
	return
    }
    fmt.Println("template id: ",templateId)

    // lookup group id
    hostgroupId := GetHostGroupId(api,*hostGroupName)
    if hostgroupId == "" {
	fmt.Println("Could not resolve hostgroupId, exiting")
	return
    }
    fmt.Println("hostgroup id: ",hostgroupId)

    // create zabbix host definition
    isCreated := CreateZabbixHost(api,*hostName,templateId,hostgroupId,*IP)
    if !isCreated {
	fmt.Println("Could not create host, exiting")
	return
    }

    // lookup newly created host definition
    host := GetZabbixHost(api,*hostName)
    if host == nil {
 	fmt.Println("ERROR Could not lookup newly created host: ",hostName)
        return
    }
    fmt.Printf("new host %s with id: %s\n",*hostName,host["hostid"])


    // logout
    _, err = api.Logout()
    if err != nil {
        fmt.Println(err)
        return
    }
    fmt.Println("Logged out")


}

func PrettyPrint(v interface{}) {
      //fmt.Printf("%+v\n",response)
      b, _ := json.MarshalIndent(v, "", "  ")
      println(string(b))
}

func ShowSelfDetails(api *zabbix.API) bool {
    params := make(map[string]interface{},0)
    params["output"] = "extend"
    ret,err := api.User("get", params)
    if err !=nil { return false }
    PrettyPrint(ret)
    return true
}

func GetTemplateId(api *zabbix.API,templateName string) string {
    params := make(map[string]interface{},0)
    params["output"] = "extend"
    
    filter := make(map[string]string, 0)
    filter["host"] = templateName
    params["filter"] = filter

    // make sure no error or empty results
    ret,err := api.Template("get", params)
    if err !=nil || len(ret)<1 { return "" }

    // pull string out of generic interface
    if tid, ok := ret[0]["templateid"].(string); ok {
	return tid
    }else {
        return ""
    }
}

func GetHostGroupId(api *zabbix.API,hostgroupName string) string {
    params := make(map[string]interface{},0)
    params["output"] = "extend"
    
    filter := make(map[string]string, 0)
    filter["name"] = hostgroupName 
    params["filter"] = filter

    // make sure no error or empty results
    ret,err := api.HostGroup("get", params)
    if err !=nil || len(ret)<1 { return "" }

    // pull string out of generic interface
    if gid, ok := ret[0]["groupid"].(string); ok {
	return gid
    }else {
        return ""
    }
}

func CreateZabbixHost(api *zabbix.API,hostName string,templateId string,hostGroupId string,IP string) bool {

    // create parameters for call
    params := make(map[string]interface{},0)

    params["inventory_mode"] = "1"
    params["host"] = hostName

    groups := make([]map[string]interface{}, 1)
    groups[0] = make(map[string]interface{})
    groups[0]["groupid"] = hostGroupId
    params["groups"] = groups

    templates := make([]map[string]string, 1)
    templates[0] = make(map[string]string)
    templates[0]["templateid"] = templateId
    params["templates"] = templates

    inters := make([]map[string]interface{}, 1)
    inters[0] = make(map[string]interface{})
    inters[0]["type"] = "1"
    inters[0]["main"] = "1"
    inters[0]["useip"] = "1"
    inters[0]["ip"] = IP
    inters[0]["dns"] = ""
    inters[0]["port"] = "10050"
    params["interfaces"] = inters

    // make host.create call
    // unfortunately, generic Host call will not return host info
    // this is a limitation of the go client, not zabbix
    _, err := api.Host("create", params)
    if err != nil {
	fmt.Println("ERROR!!!!",err)
	return false
    }
    //fmt.Printf("%+v\n",ret)
    //PrettyPrint(ret)

    return true
}


func GetZabbixHost(api *zabbix.API,hostName string) zabbix.ZabbixHost {
    params := make(map[string]interface{},0)
    params["output"] = "extend"
    
    filter := make(map[string]string, 0)
    filter["host"] = hostName 
    params["filter"] = filter

    // make sure no error or empty results
    ret,err := api.Host("get", params)
    if err !=nil || len(ret)<1 { return nil }

    return ret[0]
}
