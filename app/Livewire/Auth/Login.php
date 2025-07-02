<?php

namespace App\Livewire\Auth;

use Livewire\Component;
use Livewire\Attributes\Layout;
use Livewire\Attributes\Title;

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
}
