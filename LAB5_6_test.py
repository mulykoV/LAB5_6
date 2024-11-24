import unittest
from unittest.mock import patch
from io import StringIO
from LAB5_6_master import NotesStackApp  
from junit_xml import TestSuite, TestCase
import os  # Додаємо імпорт модуля os для створення директорії

class TestNotesStackApp(unittest.TestCase):

    def setUp(self):
        self.app = NotesStackApp(self.root)

    def tearDown(self):
        # Знищуємо вікно після кожного тесту
        self.root.destroy()

    def test_add_note_success(self):
        # Тест на успішне додавання нотатки
        self.app.entry.insert(0, "Test note")
        self.app.add_note()
        self.assertIn("Test note", self.app.stack)
        self.assertEqual(self.app.notes_display.get("1.0", "end-1c").strip(), "Test note")

    @patch("tkinter.messagebox.showwarning")
    def test_add_empty_note(self, mock_showwarning):
        # Тест на додавання порожньої нотатки
        self.app.entry.delete(0, "end")
        self.app.add_note()
        mock_showwarning.assert_called_once_with("Помилка", "Нотатка не може бути порожньою!")
        self.assertEqual(len(self.app.stack), 0)

    def test_remove_note_success(self):
        # Тест на успішне видалення нотатки
        self.app.stack = ["Test note 1", "Test note 2"]
        self.app.remove_note()
        self.assertNotIn("Test note 2", self.app.stack)
        self.assertEqual(self.app.notes_display.get("1.0", "end-1c").strip(), "Test note 1")

    @patch("tkinter.messagebox.showwarning")
    def test_remove_note_empty_stack(self, mock_showwarning):
        # Тест на спробу видалити нотатку з порожнього стеку
        self.app.stack = []
        self.app.remove_note()
        mock_showwarning.assert_called_once_with("Помилка", "Стек порожній, нічого видаляти!")

    def test_clear_notes(self):
        # Тест на очищення нотаток
        self.app.stack = ["Test note 1", "Test note 2"]
        self.app.clear_notes()
        self.assertEqual(len(self.app.stack), 0)
        self.assertEqual(self.app.notes_display.get("1.0", "end-1c").strip(), "")

    @patch("builtins.open", new_callable=unittest.mock.mock_open)
    @patch("tkinter.messagebox.showinfo")
    def test_save_notes_success(self, mock_showinfo, mock_open):
        # Тест на успішне збереження нотаток у файл
        self.app.stack = ["Test note 1", "Test note 2"]
        self.app.save_notes()
        mock_open.assert_called_once_with("notes.txt", "w")
        mock_open().write.assert_any_call("Test note 1\n")
        mock_open().write.assert_any_call("Test note 2\n")
        mock_showinfo.assert_called_once_with("Збережено", "Нотатки успішно збережені у файл notes.txt!")

    @patch("tkinter.messagebox.showwarning")
    def test_save_notes_empty_stack(self, mock_showwarning):
        # Тест на спробу збереження порожнього стеку
        self.app.stack = []
        self.app.save_notes()
        mock_showwarning.assert_called_once_with("Помилка", "Немає нотаток для збереження!")

if __name__ == '__main__':
    # Переконатися, що директорія для звітів існує
    if not os.path.exists('test-reports'):
        os.makedirs('test-reports')

    test_cases = []
    test_case = TestCase('test_example')
    test_case.stdout = 'Sample output'
    test_case.stderr = 'Sample error'
    test_cases.append(test_case)

    ts = TestSuite("my test suite", test_cases)

    # Записуємо результати тестів у файл XML
    with open('test-reports/results.xml', 'w') as f:
        TestSuite.to_file(f, [ts], prettyprint=True)