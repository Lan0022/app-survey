<?php

use Illuminate\Support\Facades\Route;
use App\Livewire\Auth\Login;
use App\Livewire\Dashboard;
use Illuminate\Support\Facades\Auth;
use Illuminate\Http\Request;
use App\Livewire\CalonPenerima;

Route::get('/', function () {
    if (Auth::check()) {
        return redirect()->route('dashboard');
    }
    return redirect()->to('login');
});

Route::get('/login', Login::class)
    ->middleware('guest')
    ->name('login');

Route::get('/logout', function (Request $request) {
    Auth::logout();
    $request->session()->flush();
    return redirect('/');
})->name('logout');

Route::get('/dashboard', Dashboard::class)
    ->middleware('auth')
    ->name('dashboard');

Route::get('calon-penerima', CalonPenerima::class)
    ->middleware('auth')
    ->name('calon-penerima');
