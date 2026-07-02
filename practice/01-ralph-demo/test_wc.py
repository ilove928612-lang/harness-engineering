# test_wc.py — 复原自 README.md「产出」一节记录的 7 项测试矩阵。
# 原始实验在 /tmp/ralph-demo 运行，Builder 生成的测试文件未存档；
# 本文件按记录的测试类 / 测试名 / 验证点忠实重建，供克隆后直接 `pytest` 复验。

import subprocess
import sys

from wc import count


def run_cli(*args):
    return subprocess.run(
        [sys.executable, "wc.py", *args],
        capture_output=True,
        text=True,
        cwd=__file__.rsplit("/", 1)[0],
    )


class TestNormalFile:
    def test_counts_lines_words_chars(self, tmp_path):
        f = tmp_path / "sample.txt"
        f.write_text("hello world\nsecond line\n")
        assert count(f.read_text()) == (2, 4, 24)

    def test_output_is_formatted_table(self, tmp_path):
        f = tmp_path / "sample.txt"
        f.write_text("hello world\n")
        result = run_cli(str(f))
        assert result.returncode == 0
        out = result.stdout
        assert out.startswith(f"File: {f}")
        assert out.count("+") >= 4  # two separator rows
        for label in ("Lines", "Words", "Chars"):
            assert f"| {label}" in out


class TestEmptyFile:
    def test_empty_file_all_zeros(self, tmp_path):
        f = tmp_path / "empty.txt"
        f.write_text("")
        assert count(f.read_text()) == (0, 0, 0)
        result = run_cli(str(f))
        assert result.returncode == 0


class TestMissingFile:
    def test_missing_file_exits_nonzero(self, tmp_path):
        result = run_cli(str(tmp_path / "nope.txt"))
        assert result.returncode == 1

    def test_missing_file_prints_error(self, tmp_path):
        result = run_cli(str(tmp_path / "nope.txt"))
        assert "Error: file not found" in result.stderr


class TestNoArgs:
    def test_no_args_exits_nonzero(self):
        result = run_cli()
        assert result.returncode == 1

    def test_no_args_prints_usage(self):
        result = run_cli()
        assert "Usage: wc.py <filename>" in result.stderr
