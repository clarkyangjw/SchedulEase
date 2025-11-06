package com.cstar.schedulease.service.client.service.impl;

import com.cstar.schedulease.exception.ResourceNotFoundException;
import com.cstar.schedulease.service.client.dto.ClientDTO;
import com.cstar.schedulease.service.client.entity.Client;
import com.cstar.schedulease.service.client.repository.ClientRepository;
import com.cstar.schedulease.service.client.service.ClientService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
@Transactional
public class ClientServiceImpl implements ClientService {

    private final ClientRepository clientRepository;

    @Override
    public ClientDTO createClient(ClientDTO dto) {
        log.info("Creating new client: {} {}", dto.getFirstName(), dto.getLastName());
        
        Client client = new Client();
        client.setFirstName(dto.getFirstName());
        client.setLastName(dto.getLastName());
        client.setPhone(dto.getPhone());
        
        Client savedClient = clientRepository.save(client);
        log.info("Client created successfully with id: {}", savedClient.getId());
        
        return convertToDTO(savedClient);
    }

    @Override
    @Transactional(readOnly = true)
    public ClientDTO getClientById(Long id) {
        log.info("Fetching client with id: {}", id);
        
        Client client = clientRepository.findById(id)
            .orElseThrow(() -> ResourceNotFoundException.forId("Client", id));
        
        return convertToDTO(client);
    }

    @Override
    @Transactional(readOnly = true)
    public List<ClientDTO> getAllClients() {
        log.info("Fetching all clients");
        
        List<Client> clients = clientRepository.findAll();
        
        log.info("Found {} clients", clients.size());
        return clients.stream()
            .map(this::convertToDTO)
            .collect(Collectors.toList());
    }

    @Override
    public ClientDTO updateClient(Long id, ClientDTO dto) {
        log.info("Updating client with id: {}", id);
        
        Client client = clientRepository.findById(id)
            .orElseThrow(() -> ResourceNotFoundException.forId("Client", id));
        
        if (dto.getFirstName() != null) {
            client.setFirstName(dto.getFirstName());
        }
        if (dto.getLastName() != null) {
            client.setLastName(dto.getLastName());
        }
        if (dto.getPhone() != null) {
            client.setPhone(dto.getPhone());
        }
        
        Client updatedClient = clientRepository.save(client);
        log.info("Client updated successfully with id: {}", updatedClient.getId());
        
        return convertToDTO(updatedClient);
    }

    private ClientDTO convertToDTO(Client client) {
        ClientDTO dto = new ClientDTO();
        dto.setId(client.getId());
        dto.setFirstName(client.getFirstName());
        dto.setLastName(client.getLastName());
        dto.setPhone(client.getPhone());
        return dto;
    }
}

