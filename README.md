Monitor
===
Simple program to parse output from /proc/net/dev, and show internet download speed

```
./monitor
	-f 		file to save output
	-s 		show output
	-d 		delay
	-h 		show help
```
eg this will printout and save (and update) a file XYZ
```bash
./monitor.sh -s -f XYZ
```
### usage with i3status
edit /etc/i3status.conf
```
order += "read_file band"
[...]
read_file band{
        path = "path/to/output/file"
}
```
add to the .config/i3/status
```
exec bash /path/to/monitor.sh -f /path/to/output/file
```
![1](https://user-images.githubusercontent.com/64653975/122777415-4e9c3500-d2ac-11eb-868e-f206ab2457c1.gif)
![2](https://user-images.githubusercontent.com/64653975/122777423-4f34cb80-d2ac-11eb-9a04-5a062d1c0c36.gif)
