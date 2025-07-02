<?php

namespace App\Livewire;

use Livewire\Component;
use App\Models\CalonPenerima as CalonPenerimaModel;
use Livewire\WithPagination;

class CalonPenerima extends Component
{
    use WithPagination;

    // Properti untuk data dan form
    public $calonPenerimas, $nik, $nama_lengkap, $tempat_lahir, $tanggal_lahir, $jenis_kelamin, $agama, $pendidikan_terakhir, $no_telepon, $email, $status_perkawinan, $alamat_lengkap, $rt, $rw, $kelurahan, $kecamatan, $kabupaten_kota, $provinsi, $kode_pos;
    public $id_penerima;
    public $isModalOpen = 0;
    public $search = '';

    // Method render untuk menampilkan view
    public function render()
    {
        $query = CalonPenerimaModel::query();

        if ($this->search) {
            $query->where('nama_lengkap', 'like', '%' . $this->search . '%')
                ->orWhere('nik', 'like', '%' . $this->search . '%');
        }

        return view('livewire.calon-penerima', [
            'penerimas' => $query->paginate(10)
        ]);
    }

    // Method untuk menampilkan modal tambah data
    public function create()
    {
        $this->resetCreateForm();
        $this->openModal();
    }

    // Method untuk membuka modal
    public function openModal()
    {
        $this->isModalOpen = true;
    }

    // Method untuk menutup modal
    public function closeModal()
    {
        $this->isModalOpen = false;
    }

    // Method untuk mereset form
    private function resetCreateForm()
    {
        $this->id_penerima = null;
        $this->nik = '';
        $this->nama_lengkap = '';
        $this->tempat_lahir = '';
        $this->tanggal_lahir = '';
        $this->jenis_kelamin = '';
        $this->agama = '';
        $this->pendidikan_terakhir = '';
        $this->no_telepon = '';
        $this->email = '';
        $this->status_perkawinan = '';
        $this->alamat_lengkap = '';
        $this->rt = '';
        $this->rw = '';
        $this->kelurahan = '';
        $this->kecamatan = '';
        $this->kabupaten_kota = '';
        $this->provinsi = '';
        $this->kode_pos = '';
    }

    // Method untuk menyimpan data (baik baru maupun update)
    public function store()
    {
        $this->validate([
            'nik' => 'required|digits:16|unique:calon_penerima,nik,' . $this->id_penerima . ',id_penerima',
            'nama_lengkap' => 'required|string|max:100',
            'jenis_kelamin' => 'required',
            'tanggal_lahir' => 'required|date',
            'alamat_lengkap' => 'required',
        ]);

        CalonPenerimaModel::updateOrCreate(['id_penerima' => $this->id_penerima], [
            'nik' => $this->nik,
            'nama_lengkap' => $this->nama_lengkap,
            'tempat_lahir' => $this->tempat_lahir,
            'tanggal_lahir' => $this->tanggal_lahir,
            'jenis_kelamin' => $this->jenis_kelamin,
            'agama' => $this->agama,
            'pendidikan_terakhir' => $this->pendidikan_terakhir,
            'no_telepon' => $this->no_telepon,
            'email' => $this->email,
            'status_perkawinan' => $this->status_perkawinan,
            'alamat_lengkap' => $this->alamat_lengkap,
            'rt' => $this->rt,
            'rw' => $this->rw,
            'kelurahan' => $this->kelurahan,
            'kecamatan' => $this->kecamatan,
            'kabupaten_kota' => $this->kabupaten_kota,
            'provinsi' => $this->provinsi,
            'kode_pos' => $this->kode_pos,
        ]);

        session()->flash('message', $this->id_penerima ? 'Data Calon Penerima Berhasil Diperbarui.' : 'Data Calon Penerima Berhasil Ditambahkan.');

        $this->closeModal();
        $this->resetCreateForm();
    }

    // Method untuk menampilkan data yang akan di-edit
    public function edit($id)
    {
        $penerima = CalonPenerimaModel::findOrFail($id);
        $this->id_penerima = $id;
        $this->nik = $penerima->nik;
        $this->nama_lengkap = $penerima->nama_lengkap;
        $this->tempat_lahir = $penerima->tempat_lahir;
        $this->tanggal_lahir = $penerima->tanggal_lahir;
        $this->jenis_kelamin = $penerima->jenis_kelamin;
        $this->agama = $penerima->agama;
        $this->pendidikan_terakhir = $penerima->pendidikan_terakhir;
        $this->no_telepon = $penerima->no_telepon;
        $this->email = $penerima->email;
        $this->status_perkawinan = $penerima->status_perkawinan;
        $this->alamat_lengkap = $penerima->alamat_lengkap;
        $this->rt = $penerima->rt;
        $this->rw = $penerima->rw;
        $this->kelurahan = $penerima->kelurahan;
        $this->kecamatan = $penerima->kecamatan;
        $this->kabupaten_kota = $penerima->kabupaten_kota;
        $this->provinsi = $penerima->provinsi;
        $this->kode_pos = $penerima->kode_pos;

        $this->openModal();
    }

    // Method untuk menghapus data
    public function delete($id)
    {
        CalonPenerimaModel::find($id)->delete();
        session()->flash('message', 'Data Calon Penerima Berhasil Dihapus.');
    }
}
