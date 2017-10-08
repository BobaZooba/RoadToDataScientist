from tkinter import *

ECLIPSES_SIZE = {
    'red': [[200, 50], [300, 150]],
    'yellow': [[200, 200], [300, 300]],     #координаты кругов светофора
    'green': [[200, 350], [300, 450]]
}

colors = {
            'red': ['gray50', 'red'],
            'yellow': ['gray50', 'yellow'],
            'green': ['gray50', 'green']
        }

root = Tk()    # класс tkinter
canvas = Canvas(root, width=500, height=500, bg="black")        # холст для рисования

but_start = Button(root,
                   text="Старт",            # надпись на кнопке
                   width=10, height=5,      # ширина и высота
                   bg="green", fg="black")  # цвет фона и надписи
but_stop = Button(root,
                  text="Стоп",
                  width=10, height=5,
                  bg="red", fg="black")

def _change_color(ellipse):         # функция смены цвета

    colors[ellipse] = [colors[ellipse][1], colors[ellipse][0]] #меняем цвета в списке местами
    canvas.itemconfig(ellipses[ellipse], fill=colors[ellipse][0]) #присваиваем значение нового цвета

def blink_green():                  # функция моргания зеленного цвета

    _change_color(ellipse='green')  # меняем цвет зеленного круга
    canvas.after(500, blink_green)  # устанавливаем задержку времени

def stop_blink():                   # функция остановки моргания зеленного цвета
    canvas.after(0, blink_green)    # снимаем задержку времени

def _pass(event):                   #пустая функция
    pass

def start(event):                   # функция работы светофора

    # global d
    # if d:
    #     remove(event)
    #     but_start.bind("<Button-1>", start)
    #     canvas.after_cancel(canvas.after(12050, start, event))

    but_start.bind("<Button-1>", _pass)             #отключаем запуск кнопкой старт
    canvas.after(0, _change_color, 'green')
    canvas.after(3000, _change_color, 'green')
    canvas.after(3000, blink_green)
    canvas.after(6000, stop_blink)
    canvas.after(6000, _change_color,'yellow')
    canvas.after(8000, _change_color, 'yellow')
    canvas.after(8000, _change_color, 'red')
    canvas.after(11000, _change_color, 'yellow')
    canvas.after(12000, _change_color, 'red')
    canvas.after(12000, _change_color, 'yellow')
    canvas.after(12050, start, event)               #бесконеный цикл выполнения


def remove(event):

    # canvas.after_cancel(canvas.after(12050, start, event))
    # but_start.bind("<Button-1>", start)
    canvas.delete('red')
    canvas.delete('yellow')
    canvas.delete('green')

def stop(event):

    but_start.bind("<Button-1>", remove)
    # canvas.after(0, start, event)
    # global d
    # d = True

    global a,b,c
    a = canvas.create_oval(ECLIPSES_SIZE['red'][0], ECLIPSES_SIZE['red'][1], fill="gray50", tag='red')
    b = canvas.create_oval(ECLIPSES_SIZE['yellow'][0], ECLIPSES_SIZE['yellow'][1], fill="gray50", tag='yellow')
    c = canvas.create_oval(ECLIPSES_SIZE['green'][0], ECLIPSES_SIZE['green'][1], fill="gray50", tag='green')

red = canvas.create_oval(ECLIPSES_SIZE['red'][0], ECLIPSES_SIZE['red'][1], fill="gray50")
yellow = canvas.create_oval(ECLIPSES_SIZE['yellow'][0], ECLIPSES_SIZE['yellow'][1], fill="gray50")
green = canvas.create_oval(ECLIPSES_SIZE['green'][0], ECLIPSES_SIZE['green'][1], fill="gray50")
but_start.bind("<Button-1>", start) # нажатие кнопки Старт запускает светофор
but_stop.bind("<Button-1>",stop)

ellipses = {
    'red': red,
    'yellow': yellow,
    'green': green
}


but_start.pack()    #отображаем кнопку старт
but_stop.pack()     #отображаем кнопку стоп
canvas.pack()       #отображаем холст

root.mainloop()     #запускаем виджет



