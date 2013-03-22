class PeriodicTasks
  
  def self.daily
    Rails.logger.info("PeriodicTasks.daily @ #{Time.now}: Start")

    begin
      Rails.logger.info("PeriodicTasks.daily @ #{Time.now}: About to send out emails")
      Mailer.send_mailshots
      Rails.logger.info("PeriodicTasks.daily @ #{Time.now}: Finished sending emails")
    rescue Exception => e
      Rails.logger.error("PeriodicTasks.daily @ #{Time.now}: ERROR:\n#{e.message}\n" + e.backtrace.join("\n"))
      $stderr.puts "=== ERROR: Nightly Emailer Failed:\n"
      $stderr.puts e.message, e.backtrace
    end

    begin
      Rails.logger.info("PeriodicTasks.daily @ #{Time.now}: About to update users ex-directory status")
      User.update_ex_directory_status
    rescue Exception => e
      Rails.logger.error("PeriodicTasks.daily @ #{Time.now}: ERROR:\n#{e.message}\n" + e.backtrace.join("\n"))
      $stderr.puts "=== ERROR: Failed updating users ex-directory status:\n"
      $stderr.puts e.message, e.backtrace
    end

    Rails.logger.info("PeriodicTasks.daily @ #{Time.now}: About to purge old sessions")
    # CGI::Session::ActiveRecordStore::Session.delete_all( ['updated_at < ?', 1.week.ago ] ) # Purge our old session table

    Rails.logger.info("PeriodicTasks.daily @ #{Time.now}: About to call RelatedList.update_all_lists_and_talks")
    RelatedList.update_all_lists_and_talks

    Rails.logger.info("PeriodicTasks.daily @ #{Time.now}: About to call RelatedTalk.update_all_lists_and_talks")
    RelatedTalk.update_all_lists_and_talks

    Rails.logger.info("PeriodicTasks.daily @ #{Time.now}: Finished")

    true
  end

end
