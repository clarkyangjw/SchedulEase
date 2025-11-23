package com.cstar.schedulease.common.factory;

import com.cstar.schedulease.common.entity.BaseUser;

public interface UserFactory<T extends BaseUser, D> {

    T createUser(D dto);
}

