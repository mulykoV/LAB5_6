class NotesStackApp:
    def __init__(self):
        self.stack = []

    def add_note(self):
        note = input("Введіть вашу нотатку: ")
        if note:
            self.stack.append(note)
            print("Нотатку додано.")
        else:
            print("Помилка: Нотатка не може бути порожньою!")

    def remove_note(self):
        if self.stack:
            removed_note = self.stack.pop()
            print(f"Видалено: {removed_note}")
        else:
            print("Помилка: Стек порожній, нічого видаляти!")

    def view_notes(self):
        if self.stack:
            print("Ваші нотатки:")
            for note in reversed(self.stack):
                print(note)
        else:
            print("Стек порожній!")

    def clear_notes(self):
        self.stack.clear()
        print("Всі нотатки очищено.")

    def save_notes(self):
        if self.stack:
            with open("notes.txt", "w") as file:
                for note in self.stack:
                    file.write(note + "\n")
            print("Нотатки успішно збережені у файл notes.txt!")
        else:
            print("Немає нотаток для збереження!")

    def run(self):
        while True:
            print("\nМеню:")
            print("1. Додати нотатку")
            print("2. Видалити останню нотатку")
            print("3. Показати всі нотатки")
            print("4. Очистити всі нотатки")
            print("5. Зберегти нотатки у файл")
            print("6. Вийти")
            choice = input("Виберіть опцію: ")

            if choice == "1":
                self.add_note()
            elif choice == "2":
                self.remove_note()
            elif choice == "3":
                self.view_notes()
            elif choice == "4":
                self.clear_notes()
            elif choice == "5":
                self.save_notes()
            elif choice == "6":
                print("Вихід з програми.")
                break
            else:
                print("Невірний вибір. Спробуйте ще раз.")


if __name__ == "__main__":
    app = NotesStackApp()
    app.run()
