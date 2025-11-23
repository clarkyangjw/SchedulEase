package com.cstar.schedulease.common.factory;

import com.cstar.schedulease.common.entity.BaseUser;
import com.cstar.schedulease.service.client.dto.ClientDTO;
import com.cstar.schedulease.service.client.entity.Client;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

/**
 * Factory for creating Client entities
 */
@Component
@Slf4j
public class ClientFactory implements UserFactory<Client, ClientDTO> {

    @Override
    public Client createUser(ClientDTO dto) {
        log.debug("Creating Client from DTO: {} {}", dto.getFirstName(), dto.getLastName());
        
        Client client = new Client();
        client.setFirstName(dto.getFirstName());
        client.setLastName(dto.getLastName());
        client.setPhone(dto.getPhone());
        
        return client;
    }
}

