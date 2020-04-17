import re

def compileOutput(assetPath, codePath, outputPath):
	with open(assetPath, "r+") as f:
		lines = f.readlines()
		
		startCopy = False

		assetArray = []

		for line in lines:
			result = re.findall("__[A-Za-z]+__", line)
			if len(result) > 0 and "lua" not in result[0]:
				startCopy = True
			if startCopy:
				assetArray.append(line)

	with open(codePath, "r+") as f:
		lines = f.readlines()

		codeArray = []

		for line in lines:
			result = re.findall("__[A-Za-z]+__", line)
			if len(result) > 0 and "lua" not in result[0]:
				break
			codeArray.append(line)

	with open(outputPath, "w+") as f:
		for line in codeArray:
			f.write(line)
		for line in assetArray:
			f.write(line)

def main():
	assetPath = "./assets.p8"
	codePath = "./code.p8"
	outputPath = "./bin/output.p8"

	compileOutput(assetPath, codePath, outputPath)

if __name__ == '__main__':
	main()