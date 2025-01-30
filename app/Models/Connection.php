<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Connection extends Model
{
    use HasFactory;
    public $timestamps = false;

    protected $table = 'connections';
    protected $primaryKey = 'connection_id';

    protected $fillable = ['host','port','username','password','user_id'];
}