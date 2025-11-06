package com.cstar.schedulease.common.entity;

import jakarta.persistence.*;
import lombok.Data;

/**
 * Base entity for users (Provider and Client)
 * Contains common fields: id, firstName, lastName
 */
@MappedSuperclass
@Data
public abstract class BaseUser {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "first_name", nullable = false, length = 100)
    private String firstName;

    @Column(name = "last_name", nullable = false, length = 100)
    private String lastName;
}

