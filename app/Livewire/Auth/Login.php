<?php

namespace App\Livewire\Auth;

use Livewire\Component;
use Livewire\Attributes\Layout;
use Livewire\Attributes\Title;
use Illuminate\Support\Facades\Auth;

class Login extends Component
{
    #[Layout('components.layouts.auth')]
    #[Title('Auth')]

    public $email;
    public $password;
    public function render()
    {
        return view('livewire.auth.login');
    }

    public function login()
    {
        $this->validate(
            rules: [
                'email' => 'required|email',
                'password' => 'required',
            ],
            messages: [
                'email.required' => 'Email can not be empty',
                'email.email' => 'Email format is not valid',
                'password.required' => 'Password can not be empty'
            ]
        );
        $data_check = [
            'email' => $this->email,
            'password' => $this->password
        ];
        if (Auth::attempt(credentials: $data_check)) {
            return redirect()->route('dashboard');
        } else {
            return session()->flash('error', 'Email or Password is incorrect');
        }
    }
}
