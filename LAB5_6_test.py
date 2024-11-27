import unittest
from unittest.mock import patch, mock_open
from io import StringIO
from LAB5_6_master import NotesStackApp
from junit_xml import TestSuite, TestCase
import os

class TestNotesStackApp(unittest.TestCase):
    def setUp(self):
        # Ініціалізація об'єкта для тестування
        self.app = NotesStackApp()

    @patch("builtins.input", return_value="Test note")
    def test_add_note_success(self, mock_input):
        # Тест успішного додавання нотатки
        with patch("builtins.print") as mock_print:
            self.app.add_note()
            self.assertIn("Test note", self.app.stack)
            mock_print.assert_any_call("Нотатку додано.")

    @patch("builtins.input", return_value="")
    def test_add_empty_note(self, mock_input):
        # Тест додавання порожньої нотатки
        with patch("builtins.print") as mock_print:
            self.app.add_note()
            self.assertEqual(len(self.app.stack), 0)
            mock_print.assert_any_call("Помилка: Нотатка не може бути порожньою!")

    def test_remove_note_success(self):
        # Тест успішного видалення нотатки
        self.app.stack = ["Note 1", "Note 2"]
        with patch("builtins.print") as mock_print:
            self.app.remove_note()
            self.assertNotIn("Note 2", self.app.stack)
            mock_print.assert_any_call("Видалено: Note 2")

    def test_remove_note_empty_stack(self):
        # Тест видалення нотатки з порожнього стеку
        self.app.stack = []
        with patch("builtins.print") as mock_print:
            self.app.remove_note()
            mock_print.assert_any_call("Помилка: Стек порожній, нічого видаляти!")

    def test_view_notes(self):
        # Тест перегляду нотаток
        self.app.stack = ["Note 1", "Note 2"]
        with patch("builtins.print") as mock_print:
            self.app.view_notes()
            mock_print.assert_any_call("Ваші нотатки:")
            mock_print.assert_any_call("Note 2")
            mock_print.assert_any_call("Note 1")

    def test_view_notes_empty_stack(self):
        # Тест перегляду порожнього стеку
        self.app.stack = []
        with patch("builtins.print") as mock_print:
            self.app.view_notes()
            mock_print.assert_any_call("Стек порожній!")

    def test_clear_notes(self):
        # Тест очищення нотаток
        self.app.stack = ["Note 1", "Note 2"]
        with patch("builtins.print") as mock_print:
            self.app.clear_notes()
            self.assertEqual(len(self.app.stack), 0)
            mock_print.assert_any_call("Всі нотатки очищено.")

    @patch("builtins.open", new_callable=mock_open)
    def test_save_notes_success(self, mock_open_func):
        # Тест успішного збереження нотаток у файл
        self.app.stack = ["Note 1", "Note 2"]
        with patch("builtins.print") as mock_print:
            self.app.save_notes()
            mock_open_func.assert_called_once_with("notes.txt", "w")
            mock_open_func().write.assert_any_call("Note 1\n")
            mock_open_func().write.assert_any_call("Note 2\n")
            mock_print.assert_any_call("Нотатки успішно збережені у файл notes.txt!")

    @patch("builtins.print")
    def test_save_notes_empty_stack(self, mock_print):
        # Тест спроби збереження порожнього стеку
        self.app.stack = []
        self.app.save_notes()
        mock_print.assert_any_call("Немає нотаток для збереження!")

if __name__ == "__main__":
    # Переконатися, що директорія для звітів існує
    if not os.path.exists("test-reports"):
        os.makedirs("test-reports")

    # Запускаємо тести
    loader = unittest.TestLoader()
    suite = loader.loadTestsFromTestCase(TestNotesStackApp)

    # Запуск тестів і збереження у XML
    results = unittest.TextTestRunner(verbosity=2).run(suite)
    test_cases = []
    for test, result in zip(suite, results.failures + results.errors + results.testsRun):
        test_case = TestCase(test.id())
        test_case.add_failure_info(message=result[1] if result else "")
        test_cases.append(test_case)

    ts = TestSuite("NotesStackApp Tests", test_cases)
    with open("test-reports/results.xml", "w") as f:
        TestSuite.to_file(f, [ts], prettyprint=True)
