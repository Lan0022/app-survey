<div>
    <div class="card-body">

        <div class="pt-4 pb-2">
            <h5 class="card-title text-center pb-0 fs-4">Login to Your Account</h5>
            <p class="text-center small">Enter your username & password to login</p>
        </div>

        @if (session()->has('error'))
            <div class="invalid-feedback">
                {{ session('error') }}
            </div>
        @endif

        <form wire:submit="login" class="row g-3 needs-validation" novalidate>

            <div class="col-12">
                <label for="yourUsername" class="form-label">Username</label>
                <div class="input-group has-validation">
                    <span class="input-group-text" id="inputGroupPrepend">@</span>
                    <input type="text" name="username" class="form-control @error('email') is-invalid @enderror"
                        wire:model="email" id="email" required>
                    <div class="invalid-feedback"> @error('email')
                            {{ $message }}
                        @enderror
                    </div>
                </div>
            </div>

            <div class="col-12">
                <label for="yourPassword" class="form-label">Password</label>
                <input type="password" name="password" class="form-control @error('password') is-invalid @enderror"
                    wire:model="password" id="password" required>
                <div class="invalid-feedback"> @error('password')
                        {{ $message }}
                    @enderror
                </div>
            </div>

            <div class="col-12">
                <div class="form-check">
                    <input class="form-check-input" type="checkbox" name="remember" value="true" id="rememberMe">
                    <label class="form-check-label" for="rememberMe">Remember me</label>
                </div>
            </div>
            <div class="col-12">
                <button class="btn btn-primary w-100" type="submit">Login</button>
            </div>
            <div class="col-12">
                <p class="small mb-0">Don't have account? <a href="pages-register.html">Create an account</a></p>
            </div>
        </form>

    </div>
    {{-- Because she competes with no one, no one can compete with her. --}}
</div>
