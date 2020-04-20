import subprocess
import shutil
import os
import sys

sourceName = "tema1.asm"

if sys.platform.startswith('win32'):
	objName = "tema1.obj"
	execName = "tema1.exe"
	sasmPath = "C:\\Program Files\\SASM"
	nasmPath = sasmPath + "\\NASM\\nasm.exe"
	linkerPath = sasmPath + "\\MinGW\\bin\\gcc.exe"
	assemblyOptions = "-g -f win32 -o " + objName + " " + sourceName
	useShell = False
	ioFile = "includes\\io-windows.inc"
	macroObj = "objects\\macro.obj"
else:
	objName = "tema1.o"
	execName = "tema1"
	nasmPath = "nasm"
	linkerPath = "gcc"
	assemblyOptions = "-g -f elf32 -o " + objName + " " + sourceName
	useShell = True
	macroObj = "objects/macro.o"
	ioFile = "includes/io-linux.inc"

shutil.copy(ioFile, "io.inc")

inputFileName = "input.inc"
linkingOptions = objName + " " + macroObj + " -g -o " + execName + " -m32"

numTests = 80
numPassed = 0

header = "======================= Tema 1 IOCLA ======================="
print("\n" + header + "\n")

for n in range(1, numTests + 1):
	shutil.copy("inputs/input" + str(n) + ".inc", inputFileName)

	return_code = subprocess.call(nasmPath + " " + assemblyOptions, shell=useShell)
	if return_code != 0:
		result = "failed"
	else:
		return_code = subprocess.call(linkerPath + " " + linkingOptions, shell=useShell)
		if return_code != 0:
			result = "failed"
		else:
			proc = os.popen('.' + os.sep + 'tema1')
			result = proc.read().strip()
			proc.close()

			expectedResult = open("outputs/output" + str(n)).read()
			print(result)
			print(expectedResult)
			if expectedResult == result:
				result = "passed"
				numPassed += 1
			else:
				result = "failed"

	start = "Test " + str(n)
	print(start + "." * (len(header) - len(result) - len(start)) + result)

totalScore = "Result: " + str(numPassed) + "/" + str(numTests)
print("\n" + " " * (len(header) - len(totalScore)) + totalScore)

os.remove(objName)
os.remove(execName)
os.remove(inputFileName)
os.remove("io.inc")
