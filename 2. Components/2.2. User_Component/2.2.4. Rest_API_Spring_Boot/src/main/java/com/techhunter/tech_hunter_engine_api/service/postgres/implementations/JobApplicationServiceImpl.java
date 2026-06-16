package com.techhunter.tech_hunter_engine_api.service.postgres.implementations;

import com.techhunter.tech_hunter_engine_api.dto.mongo.HiredStudentJson;
import com.techhunter.tech_hunter_engine_api.dto.postgres.binding.JobApplicationDTO;
import com.techhunter.tech_hunter_engine_api.model.postgres.binding.JobApplicationEntity;
import com.techhunter.tech_hunter_engine_api.model.postgres.company.JobEntity;
import com.techhunter.tech_hunter_engine_api.model.postgres.user.UserEntity;
import com.techhunter.tech_hunter_engine_api.repository.mongo.HiredStudentMongoRepository;
import com.techhunter.tech_hunter_engine_api.repository.postgres.binding.JobApplicationRepository;
import com.techhunter.tech_hunter_engine_api.repository.postgres.company.JobRepository;
import com.techhunter.tech_hunter_engine_api.repository.postgres.user.UserRepository;
import com.techhunter.tech_hunter_engine_api.service.postgres.interfaces.binding.JobApplicationService;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Service
@RequiredArgsConstructor
public class JobApplicationServiceImpl implements JobApplicationService {

    private final JobApplicationRepository repo;
    private final UserRepository userRepo;
    private final JobRepository jobRepo;
    private final HiredStudentMongoRepository hiredMongoRepo;

    @Override
    public JobApplicationDTO updateStatus(Long applicationId, String newStatus) {

        JobApplicationEntity app = repo.findById(applicationId)
                .orElseThrow(() -> new IllegalStateException("Application not found"));

        app.setStatus(newStatus);
        app.setLastUpdateDate(LocalDateTime.now());
        repo.save(app);

        if ("HIRED".equalsIgnoreCase(newStatus)) {
            saveHiredStudentToMongo(app);
        }

        return mapToDTO(app);
    }

    @Override
    public JobApplicationDTO getById(Long applicationId) {
        return repo.findById(applicationId)
                .map(this::mapToDTO)
                .orElse(null);
    }

    @Override
    public JobApplicationDTO applyToJob(Long userId, Long jobId, String salary, String source) {

        UserEntity user = userRepo.findById(userId)
                .orElseThrow(() -> new IllegalStateException("User not found"));

        JobEntity job = jobRepo.findById(jobId)
                .orElseThrow(() -> new IllegalStateException("Job not found"));

        JobApplicationEntity app = new JobApplicationEntity();
        app.setApplicationId(System.currentTimeMillis()); // sau sequence
        app.setUser(user);
        app.setJob(job);
        app.setApplyDate(LocalDate.now());
        app.setApplySource(source);
        app.setSalary(salary);
        app.setStatus("APPLIED");

        app.setCreationDate(LocalDateTime.now());
        app.setCreatedBy("system");
        app.setLastUpdateDate(LocalDateTime.now());
        app.setLastUpdatedBy("system");
        app.setSourceSystem("pg_env");
        app.setSyncStatus("synced");
        app.setSyncVersion(1L);
        app.setLastSyncedAt(LocalDateTime.now());
        app.setDeletedFlag("N");

        repo.save(app);

        return mapToDTO(app);
    }

    private void saveHiredStudentToMongo(JobApplicationEntity app) {

        UserEntity student = app.getUser();

        HiredStudentJson json = new HiredStudentJson(
                student.getUserId(),
                student.getFirstName(),
                student.getLastName(),
                student.getEmail(),
                student.getPhone(),
                student.getDateOfBirth(),
                student.getSkills(),
                student.getCertifications(),
                student.getSpecializations(),
                LocalDateTime.now(),
                app.getJob().getJobId(),
                app.getJob().getLocation().getLocationId()
        );

        hiredMongoRepo.save(json);
    }

    private JobApplicationDTO mapToDTO(JobApplicationEntity app) {
        return new JobApplicationDTO(
                app.getApplicationId(),
                app.getUser().getUserId(),
                app.getJob().getJobId(),
                app.getStatus(),
                app.getApplyDate(),
                app.getSalary(),
                app.getApplySource()
        );
    }
}