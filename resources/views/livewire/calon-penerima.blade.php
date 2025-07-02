<div>
    <div class="pagetitle">
        <h1>Data Calon Penerima</h1>
        <nav>
            <ol class="breadcrumb">
                <li class="breadcrumb-item"><a href="{{ route('dashboard') }}">Home</a></li>
                <li class="breadcrumb-item active">Data Master</li>
                <li class="breadcrumb-item active">Calon Penerima</li>
            </ol>
        </nav>
    </div><!-- End Page Title -->

    <section class="section">
        <div class="row">
            <div class="col-lg-12">

                <div class="card">
                    <div class="card-body">
                        <h5 class="card-title">Daftar Calon Penerima Bantuan</h5>

                        @if (session()->has('message'))
                            <div class="alert alert-success alert-dismissible fade show" role="alert">
                                {{ session('message') }}
                                <button type="button" class="btn-close" data-bs-dismiss="alert"
                                    aria-label="Close"></button>
                            </div>
                        @endif

                        @if ($isModalOpen)
                            @include('livewire.calon-penerima.create')
                        @endif

                        <button wire:click="create()" class="btn btn-primary mb-3"><i class="bi bi-plus-lg"></i> Tambah
                            Data</button>

                        <div class="row mb-3">
                            <div class="col-md-4">
                                <input type="text" wire:model.live.debounce.300ms="search" class="form-control"
                                    placeholder="Cari berdasarkan NIK atau Nama...">
                            </div>
                        </div>

                        <!-- Table with stripped rows -->
                        <div class="table-responsive">
                            <table class="table table-striped">
                                <thead>
                                    <tr>
                                        <th scope="col">#</th>
                                        <th scope="col">NIK</th>
                                        <th scope="col">Nama Lengkap</th>
                                        <th scope="col">Jenis Kelamin</th>
                                        <th scope="col">Alamat</th>
                                        <th scope="col">Kecamatan</th>
                                        <th scope="col" width="150px">Aksi</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    @forelse($penerimas as $index => $penerima)
                                        <tr>
                                            <th scope="row">{{ $penerimas->firstItem() + $index }}</th>
                                            <td>{{ $penerima->nik }}</td>
                                            <td>{{ $penerima->nama_lengkap }}</td>
                                            <td>{{ $penerima->jenis_kelamin == 'L' ? 'Laki-laki' : 'Perempuan' }}</td>
                                            <td>{{ $penerima->alamat_lengkap }}</td>
                                            <td>{{ $penerima->kecamatan }}</td>
                                            <td>
                                                <button wire:click="edit({{ $penerima->id_penerima }})"
                                                    class="btn btn-sm btn-primary"><i class="bi bi-pencil"></i>
                                                    Edit</button>
                                                <button wire:click.prevent="delete({{ $penerima->id_penerima }})"
                                                    onclick="confirm('Anda yakin ingin menghapus data ini?') || event.stopImmediatePropagation()"
                                                    class="btn btn-sm btn-danger"><i class="bi bi-trash"></i>
                                                    Hapus</button>
                                            </td>
                                        </tr>
                                    @empty
                                        <tr>
                                            <td colspan="7" class="text-center">Data tidak ditemukan.</td>
                                        </tr>
                                    @endforelse
                                </tbody>
                            </table>
                        </div>
                        {{ $penerimas->links() }}
                        <!-- End Table with stripped rows -->

                    </div>
                </div>
            </div>
        </div>
    </section>
</div>
