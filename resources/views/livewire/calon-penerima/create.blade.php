<!-- Vertically centered Modal -->
<div class="modal fade show" id="modal-form" tabindex="-1" style="display: block;">
    <div class="modal-dialog modal-dialog-centered modal-lg">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">{{ $id_penerima ? 'Edit Data' : 'Tambah Data' }} Calon Penerima</h5>
                <button wire:click="closeModal()" type="button" class="btn-close" data-bs-dismiss="modal"
                    aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <form>
                    <div class="row">
                        <div class="col-md-6">
                            <div class="mb-3">
                                <label for="nik" class="form-label">NIK</label>
                                <input type="text" id="nik" wire:model.defer="nik"
                                    class="form-control @error('nik') is-invalid @enderror">
                                @error('nik')
                                    <div class="invalid-feedback">{{ $message }}</div>
                                @enderror
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="mb-3">
                                <label for="nama_lengkap" class="form-label">Nama Lengkap</label>
                                <input type="text" id="nama_lengkap" wire:model.defer="nama_lengkap"
                                    class="form-control @error('nama_lengkap') is-invalid @enderror">
                                @error('nama_lengkap')
                                    <div class="invalid-feedback">{{ $message }}</div>
                                @enderror
                            </div>
                        </div>
                    </div>

                    <div class="row">
                        <div class="col-md-6">
                            <div class="mb-3">
                                <label for="tempat_lahir" class="form-label">Tempat Lahir</label>
                                <input type="text" id="tempat_lahir" wire:model.defer="tempat_lahir"
                                    class="form-control">
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="mb-3">
                                <label for="tanggal_lahir" class="form-label">Tanggal Lahir</label>
                                <input type="date" id="tanggal_lahir" wire:model.defer="tanggal_lahir"
                                    class="form-control @error('tanggal_lahir') is-invalid @enderror">
                                @error('tanggal_lahir')
                                    <div class="invalid-feedback">{{ $message }}</div>
                                @enderror
                            </div>
                        </div>
                    </div>

                    <div class="row">
                        <div class="col-md-6">
                            <div class="mb-3">
                                <label for="jenis_kelamin" class="form-label">Jenis Kelamin</label>
                                <select id="jenis_kelamin" wire:model.defer="jenis_kelamin"
                                    class="form-select @error('jenis_kelamin') is-invalid @enderror">
                                    <option value="">Pilih...</option>
                                    <option value="L">Laki-laki</option>
                                    <option value="P">Perempuan</option>
                                </select>
                                @error('jenis_kelamin')
                                    <div class="invalid-feedback">{{ $message }}</div>
                                @enderror
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="mb-3">
                                <label for="agama" class="form-label">Agama</label>
                                <input type="text" id="agama" wire:model.defer="agama" class="form-control">
                            </div>
                        </div>
                    </div>

                    <div class="row">
                        <div class="col-md-6">
                            <div class="mb-3">
                                <label for="status_perkawinan" class="form-label">Status Perkawinan</label>
                                <select id="status_perkawinan" wire:model.defer="status_perkawinan"
                                    class="form-select @error('status_perkawinan') is-invalid @enderror">
                                    <option value="">Pilih...</option>
                                    <option value="Belum Kawin">Belum Kawin</option>
                                    <option value="Kawin">Kawin</option>
                                    <option value="Cerai Hidup">Cerai Hidup</option>
                                    <option value="Cerai Mati">Cerai Mati</option>
                                </select>
                                @error('status_perkawinan')
                                    <div class="invalid-feedback">{{ $message }}</div>
                                @enderror
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="mb-3">
                                <label for="pendidikan_terakhir" class="form-label">Pendidikan Terkahir</label>
                                <input type="text" id="pendidikan_terakhir" wire:model.defer="pendidikan_terakhir"
                                    class="form-control @error('pendidikan_terakhir') is-invalid @enderror">
                                @error('pendidikan_terakhir')
                                    <div class="invalid-feedback">{{ $message }}</div>
                                @enderror
                            </div>
                        </div>
                    </div>

                    <div class="mb-3">
                        <label for="alamat_lengkap" class="form-label">Alamat Lengkap</label>
                        <textarea id="alamat_lengkap" wire:model.defer="alamat_lengkap"
                            class="form-control @error('alamat_lengkap') is-invalid @enderror" rows="3"></textarea>
                        @error('alamat_lengkap')
                            <div class="invalid-feedback">{{ $message }}</div>
                        @enderror
                    </div>

                    <div class="row">
                        <div class="col-md-6">
                            <div class="mb-3">
                                <label for="rt" class="form-label">RT</label>
                                <input type="text" id="rt" wire:model.defer="rt"
                                    class="form-control @error('rt') is-invalid @enderror">
                                @error('rt')
                                    <div class="invalid-feedback">{{ $message }}</div>
                                @enderror
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="mb-3">
                                <label for="rw" class="form-label">RW</label>
                                <input type="text" id="rw" wire:model.defer="rw"
                                    class="form-control @error('rw') is-invalid @enderror">
                                @error('rw')
                                    <div class="invalid-feedback">{{ $message }}</div>
                                @enderror
                            </div>
                        </div>
                    </div>

                    <div class="row">
                        <div class="col-md-6">
                            <div class="mb-3">
                                <label for="kecamatan" class="form-label">Kecamatan</label>
                                <input type="text" id="kecamatan" wire:model.defer="kecamatan"
                                    class="form-control">
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="mb-3">
                                <label for="kabupaten_kota" class="form-label">Kabupaten/Kota</label>
                                <input type="text" id="kabupaten_kota" wire:model.defer="kabupaten_kota"
                                    class="form-control">
                            </div>
                        </div>
                    </div>

                    <!-- Anda bisa menambahkan field lainnya di sini sesuai kebutuhan -->

                </form>
            </div>
            <div class="modal-footer">
                <button wire:click="closeModal()" type="button" class="btn btn-secondary"
                    data-bs-dismiss="modal">Tutup</button>
                <button wire:click.prevent="store()" type="button" class="btn btn-primary">Simpan</button>
            </div>
        </div>
    </div>
</div>
<div class="modal-backdrop fade show"></div>
