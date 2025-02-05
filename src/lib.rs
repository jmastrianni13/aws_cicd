use std::sync;
use std::thread;

type Job = Box<dyn FnOnce() + Send + 'static>;

pub struct ThreadPool {
    workers: Vec<Worker>,
    sender: Option<sync::mpsc::Sender<Job>>,
}

impl Drop for ThreadPool {
    fn drop(&mut self) {
        drop(self.sender.take());

        for worker in &mut self.workers {
            println!("shutting down worker {}", worker.id);

            if let Some(w_thread) = worker.w_thread.take() {
                w_thread.join().unwrap();
            }
        }
    }
}

impl ThreadPool {
    pub fn new(size: usize) -> Self {
        assert!(size > 0);

        let (sender, receiver) = sync::mpsc::channel();

        let receiver = sync::Arc::new(sync::Mutex::new(receiver));

        let mut workers = Vec::with_capacity(size);

        for id in 0..size {
            workers.push(Worker::new(id, sync::Arc::clone(&receiver)));
        }

        return Self {
            workers,
            sender: Some(sender),
        };
    }

    pub fn execute<F>(&self, f: F)
    where
        F: FnOnce() + Send + 'static,
    {
        let job = Box::new(f);

        self.sender.as_ref().unwrap().send(job).unwrap();
    }
}

struct Worker {
    id: usize,
    w_thread: Option<thread::JoinHandle<()>>,
}

impl Worker {
    fn new(id: usize, receiver: sync::Arc<sync::Mutex<sync::mpsc::Receiver<Job>>>) -> Worker {
        let w_thread = thread::spawn(move || loop {
            let msg = receiver.lock().unwrap().recv();

            match msg {
                Ok(job) => {
                    println!("> worker {id} got a job; executing");

                    job();
                }
                Err(_) => {
                    println!("> worker {id} disconnected; shutting down");
                    break;
                }
            }
        });

        return Worker {
            id,
            w_thread: Some(w_thread),
        };
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::sync::mpsc;
    use std::sync::Arc;
    use std::sync::Mutex;
    use std::thread;
    use std::time::Duration;

    #[test]
    fn test_threadpool_creation() {
        let pool = ThreadPool::new(4);
        assert_eq!(pool.workers.len(), 4);
        assert!(pool.sender.is_some());
    }

    #[test]
    #[should_panic(expected = "size > 0")]
    fn test_new_threadpool_0_size() {
        ThreadPool::new(0);
    }

    #[test]
    fn test_job_execution() {
        let pool = ThreadPool::new(2);
        let (tx, rx) = mpsc::channel();

        for _ in 0..4 {
            let tx = tx.clone();
            pool.execute(move || {
                tx.send(1).unwrap();
            });
        }

        let sum: i32 = rx.iter().take(4).sum();
        assert_eq!(sum, 4);
    }

    #[test]
    fn test_threadpool_shutdown() {
        let pool = ThreadPool::new(2);
        let (tx, rx) = mpsc::channel();

        for i in 0..2 {
            let tx = tx.clone();
            pool.execute(move || {
                println!("job {} started", i);
                thread::sleep(Duration::from_millis(10));
                tx.send(()).unwrap();
                println!("job {} completed", i);
            });
        }

        drop(pool); // test Drop trait implementation

        for _ in 0..2 {
            rx.recv().unwrap();
        }

        assert_eq!(rx.try_iter().count(), 0); // assert all jobs completed before shutdown
    }

    #[test]
    fn test_worker_shutdown_message() {
        let (tx, rx) = mpsc::channel();
        let receiver = Arc::new(Mutex::new(rx));
        let worker = Worker::new(1, Arc::clone(&receiver));

        drop(tx);

        thread::sleep(Duration::from_millis(10));

        assert!(worker.w_thread.unwrap().is_finished());
    }
}
