package com.cstar.schedulease.service.client.dto;

import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@JsonInclude(JsonInclude.Include.NON_NULL)
public class ClientDTO {
    @JsonProperty(access = JsonProperty.Access.READ_ONLY)
    private Long id;
    
    private String firstName;
    private String lastName;
    private String phone;
}

