import re
import os

def compile_output(asset_path, code_path, output_path):
	if not os.path.exists(os.path.dirname(output_path)):
		try:
			os.makedirs(os.path.dirname(output_path))
		except OSError as exc: # Guard against race condition
			if exc.errno != errno.EEXIST:
				raise

	with open(asset_path, "r+") as f:
		lines = f.readlines()
		
		start_copy = False

		asset_array = []

		for line in lines:
			result = re.findall("__[A-Za-z]+__", line)
			if len(result) > 0 and "lua" not in result[0]:
				start_copy = True
			if start_copy:
				asset_array.append(line)

	with open(code_path, "r+") as f:
		lines = f.readlines()

		code_array = []

		for line in lines:
			result = re.findall("__[A-Za-z]+__", line)
			if len(result) > 0 and "lua" not in result[0]:
				break
			code_array.append(line)

	with open(output_path, "w+") as f:
		for line in code_array:
			f.write(line)
		for line in asset_array:
			f.write(line)

def main():
	asset_path = "./assets.p8"
	code_path = "./code.p8"
	output_path = "./bin/output.p8"

	compile_output(asset_path, code_path, output_path)

if __name__ == '__main__':
	main()