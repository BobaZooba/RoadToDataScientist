
def dec(func):
    def wrapper(self, *args):
        func(self, *args)
        self.d = 99

    return wrapper


class My:

    # def dec(self, func):
    #
    #     def wrapper(self):
    #         func(self)
    #         self.d = 99
    #
    #     return wrapper


    @dec
    def __init__(self, a, b, c, d):

        self.a = a
        self.b = b
        self.c = c
        self.d = d

    @dec
    def cha_c(self):
        self.c = self.d * self.b


a = My(1, 2, 3, 4)

print(a.a)
print(a.b)
print(a.c)
print(a.d)
a.cha_c()

print(a.a)
print(a.b)
print(a.c)
print(a.d)

# def method_friendly_decorator(method_to_decorate):
#     def wrapper(self, lie):
#         lie = lie - 3  # действительно, дружелюбно - снизим возраст ещё сильней :-)
#         return method_to_decorate(self, lie)
#
#     return wrapper
#
#
# class Lucy(object):
#     def __init__(self):
#         self.age = 32
#
#     @method_friendly_decorator
#     def sayYourAge(self, lie):
#         print("Мне %s, а ты бы сколько дал?" % (self.age + lie))
#
#
# l = Lucy()
# l.sayYourAge(-3)
# # выведет: Мне 26, а ты бы сколько дал?
