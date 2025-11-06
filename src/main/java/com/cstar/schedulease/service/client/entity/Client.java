package com.cstar.schedulease.service.client.entity;

import com.cstar.schedulease.common.entity.BaseUser;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;

@Entity
@Table(name = "client")
@Data
@EqualsAndHashCode(callSuper = true)
@NoArgsConstructor
@AllArgsConstructor
public class Client extends BaseUser {

    @Column(name = "phone", nullable = false, length = 20)
    private String phone;
}

