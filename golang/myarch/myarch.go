package main

import "fmt"
import "runtime"

func main() {
    fmt.Printf("Hello from: %s %s",runtime.GOOS,runtime.GOARCH)
}
