<?php

namespace App\Services;

use Vault\Client;
use Vault\Exceptions\VaultException;

class VaultService
{
    protected $vault;

    public function __construct()
    {
        // Initialize Vault client
        $this->vault = new Client([
            'base_uri' => env('VAULT_ADDR'), // Set the Vault address in .env file
            'token' => env('VAULT_TOKEN')    // Set the Vault token in .env file
        ]);
    }

    public function getDbPassword()
    {
        try {
            $secret = $this->vault->read('secret/db_credentials');
            return $secret['data']['POSTGRES_PASSWORD'];
        } catch (VaultException $e) {
            throw new \Exception('Failed to fetch the DB password from Vault');
        }
    }
}
