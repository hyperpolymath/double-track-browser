// SPDX-License-Identifier: PMPL-1.0-or-later
// Performance benchmarks for DoubleTrack core operations
// Measures throughput of critical paths

use criterion::{black_box, criterion_group, criterion_main, Criterion, BenchmarkId};
use doubletrack_core::*;
use rand::SeedableRng;

fn benchmark_profile_generation(c: &mut Criterion) {
    c.bench_function("profile_generation_with_seed", |b| {
        b.iter(|| {
            let mut gen = ProfileGenerator::new(Some(black_box(42)));
            gen.generate()
        });
    });

    c.bench_function("profile_generation_random", |b| {
        b.iter(|| {
            let mut gen = ProfileGenerator::new(None);
            gen.generate()
        });
    });
}

fn benchmark_profile_serialization(c: &mut Criterion) {
    let mut gen = ProfileGenerator::new(Some(42));
    let profile = gen.generate();

    c.bench_function("profile_to_json", |b| {
        b.iter(|| {
            serde_json::to_string(black_box(&profile))
        });
    });

    let json_str = serde_json::to_string(&profile).unwrap();

    c.bench_function("json_to_profile", |b| {
        b.iter(|| {
            serde_json::from_str::<Profile>(black_box(&json_str))
        });
    });
}

fn benchmark_activity_generation(c: &mut Criterion) {
    let mut gen = ProfileGenerator::new(Some(42));
    let profile = gen.generate();

    let mut group = c.benchmark_group("activity_generation");

    for duration_hours in [1, 24, 72].iter() {
        group.bench_with_input(
            BenchmarkId::from_parameter(format!("{}h", duration_hours)),
            duration_hours,
            |b, &duration_hours| {
                b.iter(|| {
                    let mut simulator = ActivitySimulator::new(black_box(profile.clone()));
                    simulator.generate_activities(black_box(duration_hours))
                });
            },
        );
    }
    group.finish();
}

fn benchmark_activity_count_scaling(c: &mut Criterion) {
    let mut gen = ProfileGenerator::new(Some(42));
    let profile = gen.generate();

    let mut group = c.benchmark_group("activity_scaling");

    for activity_count in [100, 1000, 10000].iter() {
        group.bench_with_input(
            BenchmarkId::from_parameter(format!("{}activities", activity_count)),
            activity_count,
            |b, &activity_count| {
                b.iter_custom(|iters| {
                    let mut total_duration = std::time::Duration::ZERO;
                    for _ in 0..iters {
                        let start = std::time::Instant::now();
                        let mut simulator =
                            ActivitySimulator::new(black_box(profile.clone()));
                        // Estimate hours needed for target activity count
                        let hours = ((activity_count as f64 / 4.0) as u32).max(1);
                        let _ = simulator.generate_activities(black_box(hours));
                        total_duration += start.elapsed();
                    }
                    total_duration
                });
            },
        );
    }
    group.finish();
}

fn benchmark_formdata_generation(c: &mut Criterion) {
    let mut gen = ProfileGenerator::new(Some(42));
    let profile = gen.generate();

    c.bench_function("formdata_generation", |b| {
        b.iter(|| {
            let mut rng = rand::rngs::SmallRng::seed_from_u64(black_box(42));
            FormDataGenerator::generate(black_box(&profile), &mut rng)
        });
    });
}

fn benchmark_schedule_generation(c: &mut Criterion) {
    let mut gen = ProfileGenerator::new(Some(42));
    let profile = gen.generate();

    c.bench_function("schedule_generation", |b| {
        b.iter(|| {
            Schedule::from_profile(black_box(&profile))
        });
    });
}

fn benchmark_validation(c: &mut Criterion) {
    let mut gen = ProfileGenerator::new(Some(42));
    let profile = gen.generate();

    c.bench_function("profile_validation", |b| {
        b.iter(|| {
            profile.is_valid()
        });
    });
}

fn benchmark_url_generation(c: &mut Criterion) {
    // URL generation is tested implicitly through activity generation,
    // as URLs are generated as part of activity creation
    let mut gen = ProfileGenerator::new(Some(42));
    let profile = gen.generate();

    let mut group = c.benchmark_group("activity_type_variety");

    for hours in [1u32, 12, 24].iter() {
        group.bench_with_input(
            BenchmarkId::from_parameter(format!("{}h", hours)),
            hours,
            |b, &hours| {
                b.iter(|| {
                    let mut simulator = ActivitySimulator::new(black_box(profile.clone()));
                    simulator.generate_activities(black_box(hours))
                });
            },
        );
    }
    group.finish();
}

fn benchmark_full_pipeline(c: &mut Criterion) {
    c.bench_function("full_pipeline_24h", |b| {
        b.iter(|| {
            // Profile generation
            let mut gen = ProfileGenerator::new(Some(black_box(42)));
            let profile = gen.generate();

            // Activities
            let mut simulator = ActivitySimulator::new(black_box(profile.clone()));
            let _activities = simulator.generate_activities(black_box(24));

            // Form data
            let mut rng = rand::rngs::SmallRng::seed_from_u64(black_box(42));
            let _form = FormDataGenerator::generate(black_box(&profile), &mut rng);

            // Schedule
            let _schedule = Schedule::from_profile(black_box(&profile));

            // Serialization
            let _json = serde_json::to_string(black_box(&profile));
        });
    });
}

criterion_group!(
    benches,
    benchmark_profile_generation,
    benchmark_profile_serialization,
    benchmark_activity_generation,
    benchmark_activity_count_scaling,
    benchmark_formdata_generation,
    benchmark_schedule_generation,
    benchmark_validation,
    benchmark_url_generation,
    benchmark_full_pipeline,
);

criterion_main!(benches);
