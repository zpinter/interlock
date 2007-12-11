
class MemCache

  def lock(key, lock_expiry = 30, retries = 5)
    retries.times do |count|
      response = CACHE.add("lock:#{key}", "Locked by #{Process.pid}", lock_expiry)
      if response == "STORED\r\n"
        begin
          value = yield(CACHE.get(key))
          CACHE.set(key, value)
          return value
        ensure 
          CACHE.delete("lock:#{key}")
        end
      else
        sleep((2**count) / 2.0)
      end
    end
    raise MemCacheError, "Couldn't acquire lock for #{key}"
  end
  
end
