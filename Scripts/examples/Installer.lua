local file = io.open("C:\\Program Files\\GCT\\Scripts\\Configs\\myfile.txt", "w")
file:write("Hello world")
file:close()

os.rename("C:\\Program Files\\GCT\\Scripts\\Configs\\myfile.txt", "C:\\Program Files\\GCT\\Scripts\\Configs\\file1.txt")
os.remove("C:\\Program Files\\GCT\\Scripts\\Configs\\file1.txt")
os.execute("echo installed")


