import unittest
from unittest.mock import patch, mock_open
from LAB5_6_master import NotesStackApp  # Замініть на правильний імпорт

class TestNotesStackApp(unittest.TestCase):

    def setUp(self):
        self.app = NotesStackApp()

    @patch("builtins.input", return_value="Test note")
    def test_add_note_success(self, mock_input):
        self.app.add_note()
        self.assertIn("Test note", self.app.stack)

    @patch("builtins.input", return_value="")
    def test_add_empty_note(self, mock_input):
        with patch("builtins.print") as mock_print:
            self.app.add_note()
            mock_print.assert_called_with("Помилка: Нотатка не може бути порожньою!")
        self.assertEqual(len(self.app.stack), 0)

    def test_remove_note_success(self):
        self.app.stack = ["Test note"]
        with patch("builtins.print") as mock_print:
            self.app.remove_note()
            mock_print.assert_called_with("Видалено: Test note")
        self.assertEqual(len(self.app.stack), 0)

    def test_remove_note_empty_stack(self):
        with patch("builtins.print") as mock_print:
            self.app.remove_note()
            mock_print.assert_called_with("Помилка: Стек порожній, нічого видаляти!")

    def test_clear_notes(self):
        self.app.stack = ["Test note"]
        with patch("builtins.print") as mock_print:
            self.app.clear_notes()
            mock_print.assert_called_with("Всі нотатки очищено.")
        self.assertEqual(len(self.app.stack), 0)

    @patch("builtins.open", new_callable=mock_open)
    def test_save_notes_success(self, mock_open):
        self.app.stack = ["Test note 1", "Test note 2"]
        with patch("builtins.print") as mock_print:
            self.app.save_notes()
            mock_open().write.assert_any_call("Test note 1\n")
            mock_open().write.assert_any_call("Test note 2\n")
            mock_print.assert_called_with("Нотатки успішно збережені у файл notes.txt!")

    @patch("builtins.print")
    def test_save_notes_empty_stack(self, mock_print):
        self.app.stack = []
        self.app.save_notes()
        mock_print.assert_called_with("Немає нотаток для збереження!")

if __name__ == "__main__":
    unittest.main()
