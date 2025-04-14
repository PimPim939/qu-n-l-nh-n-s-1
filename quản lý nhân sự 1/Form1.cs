using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace quản_lý_nhân_sự_1
{
    public partial class Form1 : Form
    {
        private List<NhanVien> danhSachNhanVien;

        public Form1()
        {
            InitializeComponent();
            danhSachNhanVien = new List<NhanVien>();
            InitializeDataGridView();
            btnThem.Click += BtnThem_Click;
            btnSua.Click += BtnSua_Click;
            btnXoa.Click += BtnXoa_Click;
            dgvNhanVien.SelectionChanged += DgvNhanVien_SelectionChanged;
        }

        private void InitializeDataGridView()
        {
            dgvNhanVien.AutoGenerateColumns = false;
            dgvNhanVien.Columns.Add("MaNV", "Mã NV");
            dgvNhanVien.Columns.Add("HoTen", "Họ tên");
            dgvNhanVien.Columns.Add("SDT", "Số điện thoại");
            dgvNhanVien.Columns.Add("Email", "Email");
            dgvNhanVien.Columns.Add("DiaChi", "Địa chỉ");
            RefreshDataGridView();
        }

        private void RefreshDataGridView()
        {
            dgvNhanVien.Rows.Clear();
            foreach (var nv in danhSachNhanVien)
            {
                dgvNhanVien.Rows.Add(nv.MaNV, nv.HoTen, nv.SDT, nv.Email, nv.DiaChi);
            }
        }

        private void ClearInputs()
        {
            txtMaNV.Clear();
            txtHoTen.Clear();
            txtSDT.Clear();
            txtEmail.Clear();
            txtDiaChi.Clear();
        }

        private bool ValidateInputs()
        {
            if (string.IsNullOrWhiteSpace(txtMaNV.Text) ||
                string.IsNullOrWhiteSpace(txtHoTen.Text) ||
                string.IsNullOrWhiteSpace(txtSDT.Text))
            {
                MessageBox.Show("Vui lòng nhập đầy đủ thông tin bắt buộc (Mã NV, Họ tên, Số điện thoại)");
                return false;
            }
            return true;
        }

        private void BtnThem_Click(object sender, EventArgs e)
        {
            if (!ValidateInputs()) return;

            if (danhSachNhanVien.Exists(x => x.MaNV == txtMaNV.Text))
            {
                MessageBox.Show("Mã nhân viên đã tồn tại!");
                return;
            }

            var nhanVien = new NhanVien(
                txtMaNV.Text,
                txtHoTen.Text,
                txtSDT.Text,
                txtEmail.Text,
                txtDiaChi.Text
            );

            danhSachNhanVien.Add(nhanVien);
            RefreshDataGridView();
            ClearInputs();
            MessageBox.Show("Thêm nhân viên thành công!");
        }

        private void BtnSua_Click(object sender, EventArgs e)
        {
            if (!ValidateInputs()) return;

            var index = danhSachNhanVien.FindIndex(x => x.MaNV == txtMaNV.Text);
            if (index == -1)
            {
                MessageBox.Show("Không tìm thấy nhân viên cần sửa!");
                return;
            }

            danhSachNhanVien[index] = new NhanVien(
                txtMaNV.Text,
                txtHoTen.Text,
                txtSDT.Text,
                txtEmail.Text,
                txtDiaChi.Text
            );

            RefreshDataGridView();
            ClearInputs();
            MessageBox.Show("Cập nhật thông tin nhân viên thành công!");
        }

        private void BtnXoa_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrWhiteSpace(txtMaNV.Text))
            {
                MessageBox.Show("Vui lòng chọn nhân viên cần xóa!");
                return;
            }

            var result = MessageBox.Show(
                "Bạn có chắc chắn muốn xóa nhân viên này?",
                "Xác nhận xóa",
                MessageBoxButtons.YesNo,
                MessageBoxIcon.Question
            );

            if (result == DialogResult.Yes)
            {
                var index = danhSachNhanVien.FindIndex(x => x.MaNV == txtMaNV.Text);
                if (index != -1)
                {
                    danhSachNhanVien.RemoveAt(index);
                    RefreshDataGridView();
                    ClearInputs();
                    MessageBox.Show("Xóa nhân viên thành công!");
                }
            }
        }

        private void DgvNhanVien_SelectionChanged(object sender, EventArgs e)
        {
            if (dgvNhanVien.CurrentRow != null)
            {
                txtMaNV.Text = dgvNhanVien.CurrentRow.Cells["MaNV"].Value?.ToString();
                txtHoTen.Text = dgvNhanVien.CurrentRow.Cells["HoTen"].Value?.ToString();
                txtSDT.Text = dgvNhanVien.CurrentRow.Cells["SDT"].Value?.ToString();
                txtEmail.Text = dgvNhanVien.CurrentRow.Cells["Email"].Value?.ToString();
                txtDiaChi.Text = dgvNhanVien.CurrentRow.Cells["DiaChi"].Value?.ToString();
            }
        }
    }
}
