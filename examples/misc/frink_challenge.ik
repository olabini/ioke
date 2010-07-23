f = method(x, y, ((333 + 3/4) - x**2) * y**6 + x**2 * (11 * x**2 * y**2 - 121 * y**4 - 2) + (5 + 1/2) * y**8 + x/(2 * y))
f2 = method(x, y, x / (2 * y) - 2)

x = 77617
y = 33096

x2 = 77617.0
y2 = 33096.0

f(x, y) println
f2(x, y) println

f(x2, y2) println
f2(x2, y2) println
