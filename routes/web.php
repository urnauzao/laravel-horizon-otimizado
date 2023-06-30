<?php

use App\Http\Controllers\ProfileController;
use App\Jobs\DefaultJob;
use App\Jobs\HighJob;
use App\Jobs\LowJob;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| Web Routes
|--------------------------------------------------------------------------
|
| Here is where you can register web routes for your application. These
| routes are loaded by the RouteServiceProvider and all of them will
| be assigned to the "web" middleware group. Make something great!
|
*/

Route::get('/', function () {
    return view('welcome');
});

Route::get('/dashboard', function () {
    return view('dashboard');
})->middleware(['auth', 'verified'])->name('dashboard');

Route::middleware('auth')->group(function () {
    Route::get('/profile', [ProfileController::class, 'edit'])->name('profile.edit');
    Route::patch('/profile', [ProfileController::class, 'update'])->name('profile.update');
    Route::delete('/profile', [ProfileController::class, 'destroy'])->name('profile.destroy');
});

Route::get('jobs/low', function () {
    foreach(range(0, 50) as $i){
        LowJob::dispatch()->onQueue('low');
    }
});
Route::get('jobs/default', function () {
    foreach(range(0, 50) as $i){
        DefaultJob::dispatch()->onQueue('default');
    }
});
Route::get('jobs/high', function () {
    foreach(range(0, 50) as $i){
        HighJob::dispatch()->onQueue('high');
    }
});

require __DIR__.'/auth.php';
