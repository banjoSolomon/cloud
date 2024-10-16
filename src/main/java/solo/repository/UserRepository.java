package solo.repository;


import org.springframework.data.jpa.repository.JpaRepository;
import solo.models.User;

public interface UserRepository extends JpaRepository<User, Long> {
    User findByUsername(String username);
}
