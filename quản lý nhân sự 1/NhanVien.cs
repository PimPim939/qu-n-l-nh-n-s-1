using System;

namespace quản_lý_nhân_sự_1
{
    public class NhanVien
    {
        public string MaNV { get; set; }
        public string HoTen { get; set; }
        public string SDT { get; set; }
        public string Email { get; set; }
        public string DiaChi { get; set; }

        public NhanVien()
        {
        }

        public NhanVien(string maNV, string hoTen, string sdt, string email, string diaChi)
        {
            MaNV = maNV;
            HoTen = hoTen;
            SDT = sdt;
            Email = email;
            DiaChi = diaChi;
        }
    }
} 