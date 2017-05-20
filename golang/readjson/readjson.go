package main

import (
	"os"
	"io/ioutil"
	"encoding/json"
	"log"
)

// json named fields and generic map
type Config struct {
	Name string `json:"name"`
	Version string `json:"version"`
	Props map[string]interface{} `json:"props"`
}

func main() {

	// initialize structure
	ConfigObj := new(Config)

	// open file and read contents
	jsonFile,err := os.Open("config.json")
	if err != nil {
	  log.Printf("ERROR opening config.json %s",err)
	  return
	}
	jsonData, err := ioutil.ReadAll(jsonFile)
	if err != nil {
	  log.Printf("ERROR reading config %s",err)
	  return
	}

	// turn json into structure
	json.Unmarshal(jsonData,&ConfigObj)


	// show structured fields
	log.Printf("name/version: %s/%s\n",ConfigObj.Name,ConfigObj.Version)	

	// show unstructured map
	for key,val := range ConfigObj.Props {
	  log.Printf("key %s -> %s\n",key,val)
	}
}

