<?php

namespace App\Services;

use GuzzleHttp\Client;
use GuzzleHttp\Exception\RequestException;
use Illuminate\Support\Facades\Log;

class VaultService
{
    protected $client;
    protected $vaultUrl;
    protected $vaultToken;

    public function __construct()
    {
        // Vault base URL and token from environment variables
        $this->vaultUrl = env('VAULT_ADDR');
        $this->vaultToken = env('VAULT_TOKEN');
        
        // Create a Guzzle client
        $this->client = new Client([
            'base_uri' => $this->vaultUrl,
            'timeout'  => 30.0,
            'headers'  => [
                'X-Vault-Token' => $this->vaultToken,
            ],
        ]);
    }

    // Method to get the DB password
    public function getDbPassword()
    {
        try {
            // Make a request to Vault to get the DB password
            $response = $this->client->request('GET', '/v1/secret/data/db_password');
            $data = json_decode($response->getBody()->getContents(), true);

            // Return the password
            return $data['data']['data']['password'] ?? null;
        } catch (RequestException $e) {
            // Log the error with full Vault URL, token, and specific failure details
            Log::error('Vault request failed', [
                'vault_url' => $this->vaultUrl,
                'vault_token' => $this->vaultToken,
                'error_message' => $e->getMessage(),
                'request_uri' => '/v1/secret/data/db_password',
            ]);

            // Optionally, you can also include the full exception details for debugging purposes
            Log::error('Exception details', [
                'exception' => $e->getTraceAsString(),
            ]);

            // Return a custom message or null based on your needs
            return 'Failed to retrieve DB password from Vault.';
        }
    }
}
