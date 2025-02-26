FLAGS := -Wall -Wextra -Wpedantic -g

run:
	g++ src/*.cpp $(FLAGS) -o out.exe
	./out.exe

clean:
	rm -r *.exe