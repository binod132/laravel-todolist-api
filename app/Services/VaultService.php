<?php

namespace App\Services;

use Vault\AuthenticationStrategies\AppRoleAuthenticationStrategy;
use Vault\AuthenticationStrategies\UserPassAuthenticationStrategy;
use Vault\AuthenticationStrategies\TokenAuthenticationStrategy;
use Vault\Client;
use Laminas\Diactoros\RequestFactory;
use Laminas\Diactoros\StreamFactory;
use Laminas\Diactoros\Uri;
use Vault\Exceptions\VaultException;

class VaultService
{
    protected $vault;

    public function __construct()
    {
        // Initialize Vault client
        $uri = new Uri(env('VAULT_ADDR')); // Get Vault address from .env
        $client = new Client(
            $uri,
            new \AlexTartan\GuzzlePsr18Adapter\Client(), // PSR-18 Adapter for Guzzle
            new RequestFactory(),
            new StreamFactory()
        );

        // Set namespace if required
        $client->setNamespace('Vault); // Optional, if you're using a Vault namespace

        // Choose authentication method (for example, Token)
        $authenticated = $client
            ->setAuthenticationStrategy(new TokenAuthenticationStrategy(env('VAULT_TOKEN'))) // Vault token from .env
            ->authenticate();

        // Assign the client to the class property
        $this->vault = $client;
    }

    public function getDbPassword()
    {
        try {
            // Read the secret from Vault
            $secret = $this->vault->read('secret/db_credentials');
            return $secret['data']['POSTGRES_PASSWORD']; // Return the password from Vault
        } catch (VaultException $e) {
            throw new \Exception('Failed to fetch the DB password from Vault');
        }
    }
}
