package com.cstar.schedulease.service.client.controller;

import com.cstar.schedulease.service.client.dto.ClientDTO;
import com.cstar.schedulease.service.client.service.ClientService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/clients")
@RequiredArgsConstructor
@Slf4j
public class ClientController {

    private final ClientService clientService;

    @PostMapping
    public ResponseEntity<ClientDTO> createClient(@RequestBody ClientDTO dto) {
        log.info("REST request to create Client: {} {}", dto.getFirstName(), dto.getLastName());
        ClientDTO createdClient = clientService.createClient(dto);
        return new ResponseEntity<>(createdClient, HttpStatus.CREATED);
    }

    @GetMapping
    public ResponseEntity<List<ClientDTO>> getAllClients() {
        log.info("REST request to get all Clients");
        List<ClientDTO> clients = clientService.getAllClients();
        return ResponseEntity.ok(clients);
    }

    @GetMapping("/{id}")
    public ResponseEntity<ClientDTO> getClientById(@PathVariable Long id) {
        log.info("REST request to get Client with id: {}", id);
        ClientDTO client = clientService.getClientById(id);
        return ResponseEntity.ok(client);
    }

    @PutMapping("/{id}")
    public ResponseEntity<ClientDTO> updateClient(
            @PathVariable Long id,
            @RequestBody ClientDTO dto) {
        log.info("REST request to update Client with id: {}", id);
        ClientDTO updatedClient = clientService.updateClient(id, dto);
        return ResponseEntity.ok(updatedClient);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteClient(@PathVariable Long id) {
        log.info("REST request to delete Client with id: {}", id);
        clientService.deleteClient(id);
        return ResponseEntity.noContent().build();
    }
}

