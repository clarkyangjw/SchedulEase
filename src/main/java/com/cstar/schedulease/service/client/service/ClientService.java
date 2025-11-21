package com.cstar.schedulease.service.client.service;

import com.cstar.schedulease.service.client.dto.ClientDTO;

import java.util.List;

public interface ClientService {
    ClientDTO createClient(ClientDTO dto);

    ClientDTO getClientById(Long id);

    List<ClientDTO> getAllClients();

    ClientDTO updateClient(Long id, ClientDTO dto);

    void deleteClient(Long id);
}

