#!/usr/bin/python

import argparse
import json


def get_max_size(val):
    return {
        'head': 4,
        'axes': 13,
        'button': 45
    }.get(val, 0)


def get_key_name(val):
    return {
        'b': 'button',
        'a': 'axes',
        'h': 'head'
    }.get(val, val)


def get_button_name(name):
    return {
        "dpup": "up",
        "dpright": "right",
        "dpleft": "left",
        "dpdown": "down",
        "lefty": "leftStickY",
        "righty": "rightStickY",
        "leftx": "leftStickX",
        "rightx": "rightStickX",
        "righttrigger": "rightTrigger",
        "leftshoulder": "leftBumper",
        "rightshoulder": "rightBumper",
        "rightstick": "rightStick",
        "lefttrigger": "leftTrigger",
        "leftstick": "leftStick"
    }.get(name, name)


def save(filename, data):
    with open(filename, 'w') as file_:
        file_.write(data)


def change_endian(hexString):
    return ''.join(sum([(c,d,a,b) for a,b,c,d in zip(*[iter(hexString)]*4)], ()))


def parse_file(filePath, resPath):
    with open(filePath) as f:
    	content = f.readlines()
        result = []
	platform = ""
	for line in content:
            line = line.strip(" \t\r\n")

            if len(line) == 0:
            	continue

            if line[0] == '#': # skip OS lines
                platform = line[2:]
                continue

            tokens = line.split(',')
	    if len(tokens) <= 1:
            	continue

            gamepad = {}
            gamepad['vendorId'] = tokens[0][:16]
            gamepad['deviceId'] = tokens[0][16:32]
            if platform.lower() == "linux":
                gamepad['vendorId'] = int(change_endian(gamepad['vendorId'])[8:12], 16)
                gamepad['deviceId'] = int(change_endian(gamepad['deviceId'])[8:12], 16)
            else:
                gamepad['vendorId'] = int(change_endian(gamepad['vendorId'])[0:4], 16)
                gamepad['deviceId'] = int(change_endian(gamepad['deviceId'])[0:4], 16)

            gamepad['name'] = tokens[1]
            gamepad['mapping'] = {}
            for t in tokens:
            	if len(t) == 0:
                    continue

            	item = t.split(':')
                if len(item) <= 1 or item[0] == "platform" or len(item[0]) == 0 or len(item[1]) == 0:
                    continue

                key = get_key_name(item[1][0])
                if key not in gamepad['mapping'].keys():
                    gamepad['mapping'][key] = {}
                val = get_button_name(item[0])
                idx = item[1][1:]
                if key != "head":
                    gamepad['mapping'][key][idx] = val
                else:
                    indexes = idx.split('.')
                    first = indexes[0]
                    second = indexes[1]
                    if first not in gamepad['mapping'][key].keys():
                        gamepad['mapping'][key][first] = {}
                    gamepad['mapping'][key][first][second] = val

            result.append(gamepad)

        save(resPath, json.dumps(result))


if __name__ == '__main__':
    parser = argparse.ArgumentParser()

    parser.add_argument('file')
    parser.add_argument('output')
    args = parser.parse_args()
    parse_file(args.file, args.output)
