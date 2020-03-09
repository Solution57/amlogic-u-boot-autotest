import sys
import serial

if __name__ == '__main__':
    if len(sys.argv) > 1:
        PORT = sys.argv[1]
    if len(sys.argv) > 2:
        PROMPT = sys.argv[2]

    s = serial.serial_for_url(PORT, 115200)
    stop = False

    while not stop:
        line = s.readline()
        if line.find(PROMPT.encode()) >= 0:
            stop = True
        sys.stdout.write("> ")
        sys.stdout.write(line)

    s.close()
