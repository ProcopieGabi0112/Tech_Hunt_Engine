package com.techhunter.tech_hunter_engine_api.repository.mongo;

import com.techhunter.tech_hunter_engine_api.dto.mongo.HiredStudentJson;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface HiredStudentMongoRepository extends MongoRepository<HiredStudentJson, String> {
}
